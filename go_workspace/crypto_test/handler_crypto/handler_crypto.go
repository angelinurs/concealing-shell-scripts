package handler_crypto

import (
	"fmt"
	"strings"

	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"

	"golang.org/x/crypto/pbkdf2"
)

const BlockSize = 32

var Glob interface{}

func derivedKey(passphrase string, salt []byte) ([]byte, []byte) {
	if salt == nil {
		salt = make([]byte, 8)
	}

	return pbkdf2.Key([]byte(passphrase), salt, 10000, BlockSize, sha256.New), salt
}

func Encrypt(passphrase, plaintext string) string {
	key, salt := derivedKey(passphrase, nil)
	iv := make([]byte, 12)
	// http://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-38d.pdf
	// Section 8.2

	rand.Read(iv)
	b, _ := aes.NewCipher(key)
	aesgcm, _ := cipher.NewGCM(b)
	data := aesgcm.Seal(nil, iv, []byte(plaintext), nil)

	return hex.EncodeToString(salt) + "-" +
		hex.EncodeToString(iv) + "-" +
		hex.EncodeToString(data)
}

func Decrypt(passphrase, ciphertext string) string {
	arr := strings.Split(ciphertext, "-")

	salt, _ := hex.DecodeString(arr[0])
	iv, _ := hex.DecodeString(arr[1])
	data, _ := hex.DecodeString(arr[2])

	key, _ := derivedKey(passphrase, salt)
	b, _ := aes.NewCipher(key)
	aesgcm, _ := cipher.NewGCM(b)
	data, _ = aesgcm.Open(nil, iv, data, nil)

	return string(data)
}

/* Test function */
func GetCrypto(key string) {
	// key := "naru"
	c := Encrypt(key, "world")
	fmt.Println(c)
	fmt.Println(Decrypt(key, c))
	fmt.Println(Decrypt("hello", "c2932347953ad4a4-25f496d260de9c150fc9e4c6-20bc1f8439796cc914eb783b9996a8d9c32d45e2df"))

}
