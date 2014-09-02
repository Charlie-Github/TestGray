//
//  WordCorrector.m
//  EdibleCameraApp
//
//  Created by CharlieGao on 5/26/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "WordCorrector.h"

@implementation WordCorrector: NSObject



-(NSString*)correctWord: (NSString*)input{
    
    UITextChecker *checker = [[UITextChecker alloc] init];
    NSString *testString = input;
    NSRange checkRange = NSMakeRange(0, testString.length);
    NSRange misspelledRange = [checker rangeOfMisspelledWordInString:testString
                                                               range:checkRange
                                                          startingAt:checkRange.location
                                                                wrap:NO
                                                            language:@"en_US"];
    NSArray *arrGuessed = [checker guessesForWordRange:misspelledRange inString:testString language:@"en_US"];
    
    if ((NSNull *)arrGuessed == [NSNull null]){
         NSLog(@"Word correction: Correct!");
    }else
    {    testString = [testString stringByReplacingCharactersInRange:misspelledRange
                                                         withString:[arrGuessed objectAtIndex:0]];
    }
        for (int i=0; i<9; i++) {
            NSLog(@"Word correction: %@",arrGuessed[i]);
        }
    return testString;
    
}
@end
