//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <openssl/hmac.h>
#import <openssl/rsa.h>
#import <openssl/aes.h>
#import <openssl/pem.h>
#import <openssl/err.h>
#import <openssl/evp.h>
#import <openssl/rand.h>
#import <CommonCrypto/CommonCrypto.h>
//#import "Enc.cpp"

RSA* publicRSAKey();
RSA* privateRSAKey();

