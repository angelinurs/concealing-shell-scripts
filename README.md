# concealing-shell-scripts

## Getting started

### Download
- [ ] Download Binary of concealing-shell-scripts. 
  - [scriptor - concealing-shell-scripts](http://192.168.0.6:11180/psm-legacy/concealing-shell-scripts/-/raw/main/scriptor?ref_type=heads)
- [ ] Download script file list and .db.connection.yml
  - [script - concealing-shell-scripts](http://192.168.0.6:11180/psm-legacy/concealing-shell-scripts/-/tree/main/script?ref_type=heads)

### Clone

- [ ] [Clone with HTTP](http://192.168.0.6:11180/psm-legacy/concealing-shell-scripts.git)

```sh
mkdir psm-packaging-projects
cd psm-packaging-projects
git clone http://192.168.0.6:11180/psm-legacy/concealing-shell-scripts.git
```

## How to use

- [ ] Execution environment

``` sh
# executor
./scriptor

# original 
# - *Not required in a running environment.
#    will be removed

## db info
./script/.db.connection.yml

## scripts
./script/psm_new.yml
./script/summary_download.yml
./script/summary_misdetect.yml
./script/summary_reqtype.yml
./script/summary_statistics.yml
./script/summary_time.yml

# encoded

## db info
./script/.db.connection.enc

## scripts
./script/psm_new.enc
./script/summary_download.enc
./script/summary_misdetect.enc
./script/summary_reqtype.enc
./script/summary_statistics.enc
./script/summary_time.enc
```

- [ ] Show usages

```sh
# scriptor commands help
$ ./scriptor

== Concealing Shell Script v 1.0 ==

Usage of Concealing Shell Script v 1.0:

## encode:
  scriptor -enc -f <filename> -W

## decode:
  scriptor -dec -f <filename> -W

## run:
- scripter -run -script <scriptname : psm_new>

## option:
  -W    encode/decode password
  -dec
        Decoding mode
  -enc
        Encoding mode
  -f string
        Input file (default "./script/.db.connection.enc")
  -o string
        script stdout or filename (default "stdout")
  -run
        Running script
  -script string
        Select one
        - psm_new
        - summary_download
        - summary_misdetect
        - summary_reqtype
        - summary_statistics
        - summary_time
```

- [ ] Encode

```sh
$ ./scriptor -enc -f ./script/.db.connection.yml -W
Begin
Enter password:

> + new filename:       ./script/.db.connection_20240702_094506.enc
End
```

- [ ] Decode

```sh
$ ./scriptor -dec -f ./script/summary_download.enc -W
Begin
Enter password:

> + new filename:       ./script/summary_download_20240702_094851.yml
End
```

- [ ] Run

```sh
$ ./scriptor -run -script psm_new
Begin
2024/07/02 09:50:07 dial tcp 127.0.0.1:5431: connect: connection refused
# warning When 'psm database' interworking is not normal
```

## Author

- gipark@easycerti.com