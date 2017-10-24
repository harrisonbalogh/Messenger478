//
//  Enc.cpp
//  Messenger478
//
//  Created by Harrison Balogh on 10/23/17.
//  Copyright © 2017 Harxer. All rights reserved.
//

#include "Enc.hpp"
#include <openssl/pem.h>
#include <string.h>
#include <iostream>

using namespace std;

void myEncYeahWoo() {
    char *key =
    "-----BEGIN PUBLIC KEY-----\n"
    "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAw2S+8phpjmxdLb1NfmEy\n"
    "/VwFjk29iRsFg/WPNGLIduRK40dGvy8rJB4Ct17A4yXRG4MEKwhRagsnco8zbFrc\n"
    "Na3FN+vX508nkJgyu/E8VcqXtkc81lLjVAZoabwckI48vNzeIf3iJEDm395OKL4p\n"
    "AXd448plzynkzHQv1LWbaQKmYyME3eHTFyrvQo6QYX7FHpjzLEGG/kQDT9vAcgmS\n"
    "YnSZl5PWj55BxOW/sj4IVZifwza2EMe+UcU6RaDJmw7CQsDNXy6fi6ToF8m/9R1t\n"
    "8CZXavoDEUOEa7CHBUGVNRtxv/9LcV1WDSN4JAKKJdNAGOOwoLSzXTr17pvSE5T2\n"
    "UwIDAQAB\n"
    "-----END PUBLIC KEY-----\n";
    
    BIO *bio = BIO_new_mem_buf((void*)key, -1);
    RSA *rsa_publickey = PEM_read_bio_RSA_PUBKEY(bio, NULL, NULL, NULL);
    BIO_free(bio);
    
    if (rsa_publickey != NULL) {
        cout << "Got it." << endl;
    } else {
        cout << "Problems..." << endl;
    }
}
