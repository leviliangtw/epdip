# epdip
A simple but efficient script for expanding IP addresses in dash format, optimized with bitwise operations and multithreading. 

## Cheat Sheet

* `./epdip.sh A.B.C.D-E.F.G.H -s`
* `./epdip.sh A.B.C.D-E.F.G.H -o ips.list`
* `./epdip.sh -f ip_ranges.list -m -o ips.list`

## Context

Sometimes, you might get ip addresses in a **dash format** like `A.B.C.D-E.F.G.H`: 

```
10.10.10.253-10.10.11.3
```

However, what you need is a complete list of addresses: 

```
10.10.10.253
10.10.10.254
10.10.10.255
10.10.11.1
10.10.11.2
10.10.11.3
```

So, here is the **`epdip`** for you!

## Usage

First, you can check the usage by simply execute `epdip` alone: 

```
$ ./epdip.sh
Usage: ./epdip.sh [-f ip_range_file / ip_range] [-m] [-o output_file] [-s]

-f|--file
    Specify a list of IP ranges for expanding operations. 
-m|--multithreading
    Expand multiple IP ranges parallelly, which may cause out-of-order output. 
-o|--outputfile
    Specify a file to store expanded IPs. 
-s|--silence
    Don't print information messages additional to IPs. 
```

As for the simplest scene, let's take expanding `10.10.10.253-10.10.11.3` for example: 

```
$ ./epdip.sh 10.10.10.253-10.10.11.3
Expanding 10.10.10.253-10.10.11.3...
10.10.10.253
10.10.10.254
10.10.10.255
10.10.11.1
10.10.11.2
10.10.11.3
Expanding 10.10.10.253-10.10.11.3 succeeded!
```

When you have a list of IP ranges: 

```
$ cat ip_ranges.list
10.10.10.255-10.10.11.2
10.10.14.255-10.10.15.2

$ ./epdip.sh -f ip_ranges.list
Expanding 10.10.10.255-10.10.11.2...
10.10.10.255
10.10.11.1
10.10.11.2
Expanding 10.10.10.255-10.10.11.2 succeeded!
Expanding 10.10.14.255-10.10.15.2...
10.10.14.255
10.10.15.1
10.10.15.2
Expanding 10.10.14.255-10.10.15.2 succeeded!
```

When you feel it's too slow: 

```
$ ./epdip.sh -f ip_ranges.list -m
Expanding 10.10.10.255-10.10.11.2...
Expanding 10.10.14.255-10.10.15.2...
10.10.10.255
10.10.14.255
10.10.11.1
10.10.11.2
Expanding 10.10.10.255-10.10.11.2 succeeded!
10.10.15.1
10.10.15.2
Expanding 10.10.14.255-10.10.15.2 succeeded!
```

When you need to specify a output file: 

```
$ ./epdip.sh -f ip_ranges.list -o ips.list
Expanding 10.10.10.255-10.10.11.2...
Expanding 10.10.14.255-10.10.15.2...
Expanding 10.10.10.255-10.10.11.2 succeeded!
Expanding 10.10.14.255-10.10.15.2 succeeded!

$ cat ips.list
10.10.10.255
10.10.11.1
10.10.11.2
10.10.14.255
10.10.15.1
10.10.15.2
```

When you would like to remove the information messages: 

```
$ ./epdip.sh -f ip_ranges.list -s
10.10.10.255
10.10.11.1
10.10.11.2
10.10.14.255
10.10.15.1
10.10.15.2
```

## Performance Increasing

* Normal Execution:
    ```
    $ time ./epdip.sh -f ip_range.list -o ips.list -s

    real    0m26,176s
    user    0m19,856s
    sys     0m6,288s
    ```
* Multithreading Execution:
    ```
    $ time ./epdip.sh -f ip_range.list -o ips.list -m -s

    real    0m7,437s
    user    0m25,613s
    sys     0m9,079s
    ```