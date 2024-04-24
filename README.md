# Capture data send by Dixell XWEB300D
Because I have necessary to save parameters readings by Dixell XWEB300D, it's a monitoring and control device for Dixell controllers
like XC60CX or/and XL260L, into time series database TimescaleDB I used a technique named sniffing to capture the
packages between the client and the server.  
 
Http server is running into Dixell XWEB300D devices. In the menu application we have a runtime page where we add all devices
monitored and controlled by XWEB300D.  
 
First we start the runtime page from the server using a web browser (this is a client) and then we capture the packages arriving into our network
interface. After that we start in console the sniffer tshark (is necessary to be installed before, with command
```sudo apt install tshark``` for ubuntu systems) with command:  

```shell
tshark -V -i tun0 -Y "ip.addr==192.168.0.15 and http.response.line" -F k12text
```

In my case the interface is tun0 because I used a vpn connection and 192.168.0.15 is the ip address for the XWEB300D device
which runs the https server. For easy readings we leave it to run only the page with runtime from the XWEB300D device in the browser.  
  
The **tshark** command is filtered for our ip, and only we catch the response line, after that the output is formatted for k12text (text).  
Because the runtime pages send request at every approximate 15 seconds to fill the form we after this time catch the lines 
needed: 

```text
...
    [Request URI: http://192.168.0.15/cgi-bin/runtime.cgi]
    File Data: 460 bytes
line-based text data: text/html (8 lines)
    2|1|0|5.3|0|0|4.0|100.0|0|0|0|0|0|0|0|1|0|0|0000000000\n
    3|1|0|5.5|0|0|4.0|100.0|0|0|0|0|0|0|0|1|0|0|0000000000\n
    4|1|0|5.9|0|0|4.0|100.0|0|0|0|0|0|0|0|1|0|0|0000000000\n
    5|0|0|13.4|15.1|0.0|13.4|-20.0|-20.0|0|0|0|0|0|0|0|00000000\n
    6|1|0|-15.9|-3.7|0.0|-15.9|-20.0|-20.0|0|0|0|1|1|0|0|00000000000\n
    7|0|0|12.7|14.3|0.0|12.7|-20.0|-20.0|0|0|0|0|0|0|0|00000000\n
    8|1|0|8.6|-0.5|0.0|8.6|6.0|6.0|1|1|0|1|0|0|0|00000000\n
    9|0|0|12.8|0|0|4.0|100.0|0|0|0|0|0|0|0|0|0|0|0000000000\n
...
```
this line contains what we need to construct our sql insert command to our TimescaleDB database.  

![Screen shoot with command tshark running](./img/capture_with_tshark.png)  

Later we used this, in the database in TimescaleDB (extension under PostgreSQL), where we needed, for example, I used the Grafana server to display in nice diagrams.

>**Warning**  
> The script work only if the page where is sent the request exist and the runtime opening by web browser is not closed  
  

![Screen shoot with final script running](./img/run_script.png)  

In [version 2](https://github.com/florintanasa/capture_dixell_v2) I'm using curl to send only the command necessary, this also was obtained using tshark sniffer, and to get the answer.  
This is a more elegant solution.  



