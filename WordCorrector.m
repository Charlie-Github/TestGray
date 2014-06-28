//
//  WordCorrector.m
//  EdibleCameraApp
//
//  Created by CharlieGao on 5/26/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "WordCorrector.h"

@implementation WordCorrector: NSObject



-(NSString*)correctWord: (NSString*)input{
    
    UITextChecker *checker = [[UITextChecker alloc] init];
    NSString *testString = input;
    NSString *output = @"";
    int mark=0;
    testString = @"portner";
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
    {
        int count = [arrGuessed count];
        if (count > 20){
            count = 20;
        }
        
        testString = [self replaceWord:testString];
        
        
        for (int i=0; i<count; i++) {
            NSString *originalString = arrGuessed[i];
            
            // Method Start
            // MutableArray of String-pairs Arrays
            originalString = [self replaceWord: originalString];
            
            if ([originalString isEqualToString:testString]){
                NSLog(@"Word correction: %@",arrGuessed[i]);
                output = arrGuessed[i];
                mark = 1;
            }
            
            

        }
    }
    if(mark==0){
        output = arrGuessed[0];
    }
    NSLog(@"Word correction: %@",output);
    return output;
    
}


-(NSString*)replaceWord: (NSString*)input{
    
    NSString *testString = input;
    
    NSMutableArray *arrayOfStringsToReplace = [NSMutableArray arrayWithObjects:
                                               [NSArray arrayWithObjects:@"a",@" ",nil],
                                               [NSArray arrayWithObjects:@"e",@" ",nil],
                                               [NSArray arrayWithObjects:@"c",@" ",nil],
                                               [NSArray arrayWithObjects:@"o",@" ",nil],
                                               [NSArray arrayWithObjects:@"u",@" ",nil],
                                               nil];
    
    // For or while loop to Find and Replace strings
    
    while ([arrayOfStringsToReplace count] >= 1) {
        testString = [testString stringByReplacingOccurrencesOfString:[[arrayOfStringsToReplace objectAtIndex:0] objectAtIndex:0]
                                                           withString:[[arrayOfStringsToReplace objectAtIndex:0] objectAtIndex:1]];
        [arrayOfStringsToReplace removeObjectAtIndex:0];
    }

    return testString;
    
}


@end
