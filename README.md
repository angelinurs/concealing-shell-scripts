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
./script/summary_download_month.yml
./script/summary_reqtype_monthly.yml
./script/summary_statistics_monthly.yml
./script/summary_time_monthly.yml

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
./script/summary_download_month.enc
./script/summary_reqtype_monthly.enc
./script/summary_statistics_monthly.enc
./script/summary_time_monthly.enc

```

- [ ] Show usages

```sh
# scriptor commands help
$ ./scriptor

== Concealing Shell Script v 1.0 ==

Usage of Concealing Shell Script v 1.0

## encode:
  scriptor -enc -f <filename> -W

## decode:
  scriptor -dec -f <filename> -W

## run:
  scripter -run -script <scriptname : psm_new>
    OR
  scripter -run -script <scriptname : psm_new> -start 20030109 -end 20051231

## option:
* Encode/Decode
  -dec  Decoding mode
  -enc  Encoding mode
  -W    encode/decode password
  -f    Input file ./script/.db.connection.enc

* Run
  -run  Running script
  -script   Select one
    - psm_new
    - summary_download
    - summary_misdetect
    - summary_reqtype
    - summary_statistics
    - summary_time
    - summary_download_month
    - summary_reqtype_monthly
    - summary_statistics_monthly
    - summary_time_monthly

  ** Below options are used only when running 'psm_new' or 'month' scripts.
  -start   Start date 20230215
  -end     End date   20231231
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

$ ./scriptor -run -script psm_new -start 20030109 -end 20051231
Begin
2024/07/02 09:50:07 dial tcp 127.0.0.1:5431: connect: connection refused
# warning When 'psm database' interworking is not normal

```

## Static library build

- `go build -ldflags="-linkmode external -extldflags -static" -o scriptor main.go`

## Author

- gipark@easycerti.com