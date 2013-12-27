#import <Kiwi/Kiwi.h>
#import "BRLOptionParser.h"


SPEC_BEGIN(BRLOptionParserSpec)

describe(@"BRLOptionParser", ^{
    __block BRLOptionParser *options;
    __block NSError *error;

    beforeEach(^{
        options = [BRLOptionParser new];
        error = nil;
    });

    context(@"parsing", ^{
        context(@"options without arguments", ^{
            __block BOOL flag;
            __block char * argument;

            beforeEach(^{
                flag = NO;
                argument = "-h";
            });

            it(@"calls blocks", ^{
                [options addOption:NULL flag:'h' description:nil block:^{
                    flag = YES;
                }];
            });

            it(@"casts boolean values", ^{
                [options addOption:NULL flag:'h' description:nil value:&flag];
            });

            context(@"long options", ^{
                beforeEach(^{
                    argument = "--help";
                });

                it(@"calls blocks", ^{
                    [options addOption:"help" flag:0 description:nil block:^{
                        flag = YES;
                    }];
                });

                it(@"casts boolean values", ^{
                    [options addOption:"help" flag:0 description:nil value:&flag];
                });

                context(@"with short aliases", ^{
                    it(@"calls blocks", ^{
                        [options addOption:"help" flag:'h' description:nil block:^{
                            flag = YES;
                        }];
                    });

                    it(@"casts boolean values", ^{
                        [options addOption:"help" flag:'h' description:nil value:&flag];
                    });

                    afterEach(^{
                        int argc = 2;
                        const char * argv[] = {"app", "-h", 0};
                        [[@([options parseArgc:argc argv:argv error:&error]) should] beYes];
                        [[error should] beNil];
                    });
                });
            });

            afterEach(^{
                int argc = 2;
                const char * argv[] = {"app", argument, 0};
                [[@([options parseArgc:argc argv:argv error:&error]) should] beYes];
                [[error should] beNil];
                [[@(flag) should] beYes];
            });
        });

        context(@"options with arguments", ^{
            __block NSString *string;
            __block char * argument;

            beforeEach(^{
                string = nil;
                argument = "-H";
            });

            context(@"that are set", ^{
                it(@"calls blocks with arguments", ^{
                    [options addOption:NULL flag:'H' description:nil blockWithArgument:^(NSString *value) {
                        string = value;
                    }];
                });

                it(@"casts string arguments", ^{
                    [options addOption:NULL flag:'H' description:nil argument:&string];
                });

                context(@"long options", ^{
                    beforeEach(^{
                        argument = "--hello";
                    });

                    it(@"calls blocks with arguments", ^{
                        [options addOption:"hello" flag:0 description:nil blockWithArgument:^(NSString *value) {
                            string = value;
                        }];
                    });

                    it(@"casts string arguments", ^{
                        [options addOption:"hello" flag:0 description:nil argument:&string];
                    });

                    context(@"with short aliases", ^{
                        it(@"calls blocks with arguments", ^{
                            [options addOption:"hello" flag:'H' description:nil blockWithArgument:^(NSString *value) {
                                string = value;
                            }];
                        });

                        it(@"casts string arguments", ^{
                            [options addOption:"hello" flag:'H' description:nil argument:&string];
                        });

                        afterEach(^{
                            int argc = 3;
                            const char * argv[] = {"app", "-H", "world", 0};
                            [[@([options parseArgc:argc argv:argv error:&error]) should] beYes];
                            [[error should] beNil];
                        });
                    });
                });

                afterEach(^{
                    int argc = 3;
                    const char * argv[] = {"app", argument, "world", 0};
                    [[@([options parseArgc:argc argv:argv error:&error]) should] beYes];
                    [[error should] beNil];
                    [[string should] equal:@"world"];
                });
            });

            context(@"that are missing", ^{
                it(@"fails", ^{
                    [options addOption:NULL flag:'H' description:nil argument:&string];
                    int argc = 2;
                    const char * argv[] = {"app", argument, 0};
                    [[@([options parseArgc:argc argv:argv error:&error]) should] beNo];
                    [[error shouldNot] beNil];
                    [[@([error code]) should] equal:@(BRLOptionParserErrorCodeRequired)];
                });
            });
        });

        context(@"unrecognized arguments", ^{
            it(@"fails", ^{
                int argc = 2;
                const char * argv[] = {"app", "-hi", 0};
                [[@([options parseArgc:argc argv:argv error:&error]) should] beNo];
                [[error shouldNot] beNil];
                [[@([error code]) should] equal:@(BRLOptionParserErrorCodeUnrecognized)];
            });
        });

        context(@"methods", ^{
            __block BOOL flag;
            __block NSArray *arguments = @[@"app", @"-h"];

            beforeEach(^{
                flag = NO;
                [options addOption:NULL flag:'h' description:nil value:&flag];
            });

            it(@"works with an explicit array", ^{
                [[@([options parseArguments:arguments error:&error]) should] beYes];
                [[error should] beNil];
                [[@(flag) should] beYes];
            });

            it(@"works with implicit arguments", ^{
                [[NSProcessInfo processInfo] stub:@selector(arguments) andReturn:arguments];
                [[@([options parse:&error]) should] beYes];
                [[error should] beNil];
                [[@(flag) should] beYes];
            });
        });
    });
});

SPEC_END
