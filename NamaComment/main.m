//
//  main.m
//  NamaComment
//
//  Created by HARA Yutaka on 2012/12/06.
//  Copyright (c) 2012年 HARA Yutaka. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <MacRuby/MacRuby.h>

int main(int argc, char *argv[])
{
    return macruby_main("rb_main.rb", argc, argv);
}
