//
//  main.m
//  gitlabapi
//
//  Created by yanguo sun on 09/10/2016.
//  Copyright © 2016 Lvmama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "gitlabapi-Swift.h"
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *selfPath = [[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] stringByDeletingLastPathComponent];
        NSString *configPath = [selfPath stringByAppendingPathComponent:@"config.plist"];
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:configPath];
        
        TestCommand *aCommand = [[TestCommand alloc] initWithAconfigDic:dic];
        NSDictionary *sessionConfig = [aCommand sessionCommand];
        NSString *private_token = sessionConfig[@"private_token"];
        if (!private_token) {
            return 1;
        }
        BOOL islog = YES;
        if (islog) {
            NSLog(@"%@",private_token);
        }
        NSArray *groupsConfigArray = [aCommand groupidGetWithToken:private_token];
        NSRange toReplaceRange = NSMakeRange(0, ((NSString *)dic[@"httpipUrl"]).length);
        NSString *lviosCodeUrl = dic[@"httphostUrl"];
        NSString *pwdPath = dic[@"pwdPath"];
        [aCommand mkdirCommandWithTopath:pwdPath];
        void (^enumerateBlock)(NSDictionary *, NSUInteger, BOOL *) = ^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *projectDic = [aCommand projectGetWithGroupid:[obj[@"id"] description] token:private_token];
            NSArray *projectArray = projectDic[@"projects"];
            void (^projectBlock)(NSDictionary *, NSUInteger, BOOL *) = ^(NSDictionary * _Nonnull obj2, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *hosturl = obj2[@"http_url_to_repo"];
                hosturl = [hosturl stringByReplacingCharactersInRange:toReplaceRange withString:lviosCodeUrl];
                NSString *groupName = obj[@"name"];
                if (islog) {
                    NSLog(@"%@--%@",groupName,hosturl);
                }
                NSString *path = [pwdPath stringByAppendingPathComponent:groupName];
                [aCommand mkdirCommandWithTopath:path];
//                [aCommand gitCloneCommandWithWorkPath:path urlPath:hosturl];
                if ([[obj[@"id"] description] isEqualToString:@"90"]) { //排除的groupid
                    return;
                }
                NSString *aaa = [path stringByAppendingPathComponent:obj2[@"name"]];
                [aCommand toolCommandOneWithLaunchPath:@"/bin/bash" currentDirectoryPath:aaa arguments:@[@"-c", @"pwd"]];
                NSArray *par = @[[selfPath stringByAppendingPathComponent:@".gitignore"], aaa];
                [aCommand cpCommandFromPath:par[0] toPath:par[1]];
                [aCommand toolCommandOneWithLaunchPath:@"/usr/bin/git" currentDirectoryPath:aaa arguments:@[@"add", @"."]];
                [aCommand toolCommandOneWithLaunchPath:@"/usr/bin/git" currentDirectoryPath:aaa arguments:@[@"commit", @"-m",@"*.xcscmblueprint delete"]];
                [aCommand toolCommandOneWithLaunchPath:@"/usr/bin/git" currentDirectoryPath:aaa arguments:@[@"push", @"origin"]];
                [aCommand toolCommandOneWithLaunchPath:@"/usr/bin/git" currentDirectoryPath:aaa arguments:@[@"pull", @"origin"]];
                [aCommand toolCommandOneWithLaunchPath:@"/usr/bin/find" currentDirectoryPath:aaa arguments:@[aaa,@"-type", @"f",@"-name",@"*.xcscmblueprint", @"-exec", @"rm", @"-f",@"{}",  @"+"]];
                
            };
            
            [projectArray enumerateObjectsUsingBlock:projectBlock];
        };
        [groupsConfigArray enumerateObjectsUsingBlock:enumerateBlock];
    }
    return 0;
}
