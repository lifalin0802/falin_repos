

### how to do ssh 
```bash
ssh -L 54065:10.181.8.10:3389 81.69.234.87 -i "C:\Users\fli\.ssh\tcc-prd.pem" -m hmac-sha2-512 -l ubuntu #bastion 是个ubuntu server
81.69.234.87  - this is bastion IP
10.181.8.10   - backup in Common project
get the server wia rdp to port (54065 in the example)
```