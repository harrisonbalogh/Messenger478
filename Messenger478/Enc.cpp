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

RSA* publicRSAKey() {
    char *key =
    "-----BEGIN PUBLIC KEY-----\n"
    "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmlc8zBzNTQ2RkPnK2hrA\n"
    "cfdVyK2h1St6i5R9b5rcBhXrJninO8O69mO6xWA8DU6S6kUite0ydxbnVCCUX9L7\n"
    "n8nE6bT/olHrEBENJLj4lj9tb4vL/2vvxULJTkjQZk4XLgvWYAy5umV0E3K7xENs\n"
    "QdQcMZpdptSKR1aLTxHThsSkJRQfo6BDH7RxQjxxrpRIdA2jaoxeDQlcy/1YcgJg\n"
    "Kh4WbJOP8BdvHQeFi7LOSQV/zlw3ez5KsWE9Gc0DVPxRF4utZ0BYkQYqX0UYXNzk\n"
    "YEX/xf3+bTaZUJpDRS7MLWomWkWyZAHxM8Sjm5lAjhNzrcLSkM0SxVHc0Fy/om5z\n"
    "yQIDAQAB\n"
    "-----END PUBLIC KEY-----\n";

    
    BIO *bio = BIO_new_mem_buf((void*)key, -1);
    RSA *rsa_publickey = PEM_read_bio_RSA_PUBKEY(bio, NULL, NULL, NULL);
    
    BIO_free(bio);
    
    if (rsa_publickey != NULL) {
        return rsa_publickey;
        
    } else {
        cout << "Problems..." << endl;
    }
    return NULL;
}

RSA* privateRSAKey() {
    char *key =
    "-----BEGIN RSA PRIVATE KEY-----\n"
    "MIIEogIBAAKCAQEAmlc8zBzNTQ2RkPnK2hrAcfdVyK2h1St6i5R9b5rcBhXrJnin\n"
    "O8O69mO6xWA8DU6S6kUite0ydxbnVCCUX9L7n8nE6bT/olHrEBENJLj4lj9tb4vL\n"
    "/2vvxULJTkjQZk4XLgvWYAy5umV0E3K7xENsQdQcMZpdptSKR1aLTxHThsSkJRQf\n"
    "o6BDH7RxQjxxrpRIdA2jaoxeDQlcy/1YcgJgKh4WbJOP8BdvHQeFi7LOSQV/zlw3\n"
    "ez5KsWE9Gc0DVPxRF4utZ0BYkQYqX0UYXNzkYEX/xf3+bTaZUJpDRS7MLWomWkWy\n"
    "ZAHxM8Sjm5lAjhNzrcLSkM0SxVHc0Fy/om5zyQIDAQABAoIBAFspDcLtfCF30zPT\n"
    "Jop+ZI6r7SIz1DNpk98fnJsv16dMiPDXMMevCx3+t9Fezvl5IHN41FCqQjVu9MGO\n"
    "4LRclLzDWyhC/P6t7e42dBHtov5zhjrtUleSNDPKB8bSYS0cELrkyQFAYu8Cf3YB\n"
    "PYBl5mpXUzPFHm2seeQ67NuOBudBEWaMFbcWyLP8FwV4R9pyn07Pl8FOHX5L9KnD\n"
    "AmSFTL71q5+9jhtRupnpsPofjoWVwy4RJiustO6DbKQaVSLJSx9m1mLRKpbb5ENF\n"
    "KlDyOFJUaJEy5hg/smZjVLSjikCToUeVKnueYBbzc8lCshD3VQ54SplNDjUxaAnL\n"
    "TjVNjhECgYEAy20NC1hIwQeBFnpwz6iBN/uJM4xd4FmQ4jvzJlxMHQ+QGLFJy9d3\n"
    "uslQGJzcIpCsTadzRNbBU6Pqy22hWSttymSi2MSHFbxgkvg/7MMXPdFS++04VJW7\n"
    "xZnZD9kgXPdUb7xKw+hH69mQP7nNP+ccmb8Q8xKulJKnODidj1PHaXUCgYEAwjqj\n"
    "2yBiWVgPulkC9XlZsOPtUODBTecm2WbBFTvC2+YuFDwEi0Y2ILlMEfP14BkCOwj0\n"
    "mWHJJDAbsXnBpJYeyuRkPt6oX83TP/cGdMBU4FYiijpgft3WMbJxyuWQS/y9iYTC\n"
    "mrmzxDpCEzufyhtRkw6wOc8A/l1rIDd1mB8CwoUCgYA7lYmIlSdaQtRwvRRl/rk6\n"
    "qJabXrXwjMt/OIgT6Fzy9igC04sGBeqv719ili90gGO3qyB8PVsLIKwZQddMwwe5\n"
    "jJiWXZojp7Wx1r0CoHIiTTm9SNKDFAiX7GRD3Bk6occ9oy1TDKpkTqmNwOJ5oTwj\n"
    "XG+egw5Xvkz0jsC3xpZWMQKBgDDQehP9fJpFxpYn/tVg7UjG0AMOqaaBnMLwz0Ad\n"
    "5+hKXnRZbS7vs3Tf/R1Z+gabYnMh2g+eguXkbWFaX2+VByIo6oTeguSpHxmpZOb8\n"
    "25gSLdYdu9jGuil9VpoOvghK+fvQ8PPgDi0YEzkwOAWcfhD+lQ3CV9aV9fF/3r8f\n"
    "tBrdAoGAYRI3ytSlU+v9jF63DjlKJTKG9NPHccMeMIfaC9vQoAwKy1SmXgQINppw\n"
    "PYzvqstQN0N3E3+VSK9GSm75DH9g02Sfd61mIkcA/9BXh6mys+sIWUhdzJki4hCL\n"
    "mxcNL2hGBcRXKrehHucfSEMEXFRczYCEf/r6uwDCQyx8GLZLBKU=\n"
    "-----END RSA PRIVATE KEY-----\n";

    
    BIO *bio = BIO_new_mem_buf((void*)key, -1);
    RSA *rsa_privatekey = PEM_read_bio_RSAPrivateKey(bio, NULL, NULL, NULL);
    BIO_free(bio);
    
    if (rsa_privatekey != NULL) {
        return rsa_privatekey;
        
    } else {
        cout << "Problems..." << endl;
    }
    return NULL;
}





