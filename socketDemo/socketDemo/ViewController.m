//
//  ViewController.m
//  socketDemo
//
//  Created by chenWei on 2017/3/7.
//  Copyright © 2017年 chen. All rights reserved.
//

#import "ViewController.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *iptextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
@property (weak, nonatomic) IBOutlet UITextField *sendTextField;
@property (weak, nonatomic) IBOutlet UILabel *receiveLabel;




@end

@implementation ViewController{
    
    int socketid;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)connectButton:(UIButton *)sender {
    [self connectWithIpAddress:_iptextField.text port:[_portTextField.text intValue]];
}

- (IBAction)sendButton:(UIButton *)sender {
    NSString *receiveString = [self sendAndReceiveWithString:_sendTextField.text];
    _receiveLabel.text = receiveString;
}

- (BOOL) connectWithIpAddress: (NSString *)address port: (int)port {
    //1. 创建socket
    /*
     int socket(int domain, int type, int protocol);
     domain：协议域，又称协议族（family）。常用的协议族有AF_INET、AF_INET6、AF_LOCAL（或称AF_UNIX，Unix域
     Socket）、AF_ROUTE等。协议族决定了socket的地址类型，在通信中必须采用对应的地址，如AF_INET决定了要用ipv4地址（32位的）与端口号（16位的）的组合、AF_UNIX决定了要用一个绝对路径名作为地址。
     type：指定Socket类型。常用的socket类型有SOCK_STREAM、SOCK_DGRAM、SOCK_RAW、SOCK_PACKET、SOCK_SEQPACKET等。流式Socket（SOCK_STREAM）是一种面向连接的Socket，针对于面向连接的TCP服务应用。数据报式Socket（SOCK_DGRAM）是一种无连接的Socket，对应于无连接的UDP服务应用。
     protocol：指定协议。常用协议有IPPROTO_TCP、IPPROTO_UDP、IPPROTO_STCP、IPPROTO_TIPC等，分别对应TCP传输协议、UDP传输协议、STCP传输协议、TIPC传输协议。
     注意：1.type和protocol不可以随意组合，如SOCK_STREAM不可以跟IPPROTO_UDP组合。当第三个参数为0时，会自动选择第二个参数类型对应的默认协议。
     */
    socketid = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    NSLog(@"%d", socketid);
    
    
    //2. 建立连接
    /*
     int connect (int sockfd, struct sockaddr * serv_addr, int addrlen);
     参数
     参数一：套接字描述符
     参数二：指向数据结构sockaddr的指针，其中包括目的端口和IP地址(const struct sockaddr *)
     参数三：参数二sockaddr的长度，可以通过sizeof（struct sockaddr）获得
     返回值
     成功则返回0，失败返回非0，错误码GetLastError()。
     */
    
    struct sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    addr.sin_addr.s_addr = inet_addr(address.UTF8String);
    
    int connectResult = connect(socketid, (const struct sockaddr *)&addr, sizeof(addr));
    
    if (connectResult == 0) {
        NSLog(@"连接成功");
    } else {
        NSLog(@"连接失败");
    }
    
    return connectResult == 0;
}

- (NSString *) sendAndReceiveWithString: (NSString *)sendString {
    //3. 发送数据
    /*
     定义函数
     ssize_t send (int s,const void *msg,size_t len,int flags);
     参数说明
     第一个参数指定发送端套接字描述符；
     第二个参数指明一个存放应用程式要发送数据的缓冲区；
     第三个参数指明实际要发送的数据的字符数；
     第四个参数一般置0。
     函数说明
     send() 用来将数据由指定的 socket 传给对方主机。使用 send 时套接字必须已经连接。send 不包含传送失败的提示信息，如果检测到本地错误将返回-1。因此，如果send 成功返回，并不必然表示连接另一端的进程接收数据。所保证的仅是当send 成功返回时，数据已经无错误地发送到网络上。
     */
    send(socketid, sendString.UTF8String, strlen(sendString.UTF8String), 0);
    
    //4. 接收数据
    /*
     参数说明
     参数一: 套接字描述符
     参数二: 接收到的数据缓冲区
     参数三: 缓冲区的大小
     参数四: 默认传0
     */
    uint8_t butter[1024];
    ssize_t length = recv(socketid, butter, sizeof(butter), 0);
    NSData *data = [NSData dataWithBytes:butter length:length];
    NSString *receiveStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@", receiveStr);
    
    return receiveStr;
}

/**
 使用socket发起网络请求
 */
- (void) socketRequest {
    //1. 创建socket
    /*
     int socket(int domain, int type, int protocol);
     domain：协议域，又称协议族（family）。常用的协议族有AF_INET、AF_INET6、AF_LOCAL（或称AF_UNIX，Unix域
     Socket）、AF_ROUTE等。协议族决定了socket的地址类型，在通信中必须采用对应的地址，如AF_INET决定了要用ipv4地址（32位的）与端口号（16位的）的组合、AF_UNIX决定了要用一个绝对路径名作为地址。
     type：指定Socket类型。常用的socket类型有SOCK_STREAM、SOCK_DGRAM、SOCK_RAW、SOCK_PACKET、SOCK_SEQPACKET等。流式Socket（SOCK_STREAM）是一种面向连接的Socket，针对于面向连接的TCP服务应用。数据报式Socket（SOCK_DGRAM）是一种无连接的Socket，对应于无连接的UDP服务应用。
     protocol：指定协议。常用协议有IPPROTO_TCP、IPPROTO_UDP、IPPROTO_STCP、IPPROTO_TIPC等，分别对应TCP传输协议、UDP传输协议、STCP传输协议、TIPC传输协议。
     注意：1.type和protocol不可以随意组合，如SOCK_STREAM不可以跟IPPROTO_UDP组合。当第三个参数为0时，会自动选择第二个参数类型对应的默认协议。
     */
    int socketid = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    NSLog(@"%d", socketid);
    
    
    //2. 建立连接
    /*
     int connect (int sockfd, struct sockaddr * serv_addr, int addrlen);
     参数
     参数一：套接字描述符
     参数二：指向数据结构sockaddr的指针，其中包括目的端口和IP地址(const struct sockaddr *)
     参数三：参数二sockaddr的长度，可以通过sizeof（struct sockaddr）获得
     返回值
     成功则返回0，失败返回非0，错误码GetLastError()。
     */
    
    struct sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_port = htons(12345);
    addr.sin_addr.s_addr = inet_addr("127.0.0.1");
    
    int connectResult = connect(socketid, (const struct sockaddr *)&addr, sizeof(addr));
    
    if (connectResult == 0) {
        NSLog(@"连接成功");
    } else {
        NSLog(@"连接失败");
    }
    
    //3. 发送数据
    /*
     定义函数
     ssize_t send (int s,const void *msg,size_t len,int flags);
     参数说明
     第一个参数指定发送端套接字描述符；
     第二个参数指明一个存放应用程式要发送数据的缓冲区；
     第三个参数指明实际要发送的数据的字符数；
     第四个参数一般置0。
     函数说明
     send() 用来将数据由指定的 socket 传给对方主机。使用 send 时套接字必须已经连接。send 不包含传送失败的提示信息，如果检测到本地错误将返回-1。因此，如果send 成功返回，并不必然表示连接另一端的进程接收数据。所保证的仅是当send 成功返回时，数据已经无错误地发送到网络上。
     */
    const char *msg = "hello, world";
    send(socketid, msg, strlen(msg), 0);
    
    //4. 接收数据
    /*
     参数说明
     参数一: 套接字描述符
     参数二: 接收到的数据缓冲区
     参数三: 缓冲区的大小
     参数四: 默认传0
     */
    uint8_t butter[1024];
    ssize_t length = recv(socketid, butter, sizeof(butter), 0);
    NSData *data = [NSData dataWithBytes:butter length:length];
    NSString *receiveStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@", receiveStr);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
