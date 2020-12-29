//
//  language.m
//  libintl
//
//  Created by dev on 14-11-16.
//  Copyright (c) 2014年 youknowone.org. All rights reserved.
//

#import <Foundation/Foundation.h>

const char* getCurrentLanguage (void)
{
    
    NSString *currentLanguage = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];
    return [currentLanguage cStringUsingEncoding:NSUTF8StringEncoding];
}