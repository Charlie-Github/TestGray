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
    NSString *output = testString;
    int mark=0;
    NSRange checkRange = NSMakeRange(0, testString.length);
    NSRange misspelledRange = [checker rangeOfMisspelledWordInString:testString
                                                               range:checkRange
                                                          startingAt:checkRange.location
                                                                wrap:NO
                                                            language:@"en_US"];
    NSArray *arrGuessed = [checker guessesForWordRange:misspelledRange inString:testString language:@"en_US"];
    
    if ((NSNull *)arrGuessed == [NSNull null]){
         //NSLog(@"Word correction: Correct!");
    }else
    {
        int count = [arrGuessed count];
        if (count > 20){
            count = 20;
        }
        
        testString = [self replaceWord:testString];
        //NSLog(@"Word correction 0.0: %@", testString);
        
        for (int i=0; i<count; i++) {
            NSString *originalString = arrGuessed[i];
            //NSLog(@"Word correction0: %@",arrGuessed[i]);
            // Method Start
            // MutableArray of String-pairs Arrays
            originalString = [self replaceWord: originalString];
            
            //NSLog(@"Word correction 01: %@", originalString);
                  
            if ([originalString isEqualToString:testString]){
                //NSLog(@"Word correction1: %@",arrGuessed[i]);
                output = arrGuessed[i];
                //NSLog(@"Word correction2: %@",output);
                mark = 1;
            }
        }
//        if(mark==0){
//            output = arrGuessed[0];
//        }
    }
   
    //NSLog(@"Word correction3: %@",output);
    return output;
    
}


-(NSString*)replaceWord: (NSString*)input{
    
    NSString *testString = input;
    
    NSMutableArray *arrayOfStringsToReplace = [NSMutableArray arrayWithObjects:
                                               [NSArray arrayWithObjects:@"5",@"s",nil],
                                               [NSArray arrayWithObjects:@"3",@"a",nil],
                                               [NSArray arrayWithObjects:@"0",@"o",nil],
                                               [NSArray arrayWithObjects:@"a",@"1",nil],
                                               [NSArray arrayWithObjects:@"e",@"1",nil],
                                               [NSArray arrayWithObjects:@"c",@"1",nil],
                                               [NSArray arrayWithObjects:@"o",@"1",nil],
                                               [NSArray arrayWithObjects:@"u",@"1",nil],
                                               [NSArray arrayWithObjects:@"v",@"1",nil],
                                               [NSArray arrayWithObjects:@"i",@"2",nil],
                                               [NSArray arrayWithObjects:@"j",@"2",nil],
                                               [NSArray arrayWithObjects:@"I",@"2",nil],
                                               [NSArray arrayWithObjects:@"J",@"2",nil],
                                               [NSArray arrayWithObjects:@"L",@"2",nil],
                                               [NSArray arrayWithObjects:@"t",@"6",nil],
                                               [NSArray arrayWithObjects:@"l",@"6",nil],
                                               [NSArray arrayWithObjects:@"O",@"4",nil],
                                               [NSArray arrayWithObjects:@"Q",@"4",nil],
                                               [NSArray arrayWithObjects:@"n",@"6",nil],
                                               [NSArray arrayWithObjects:@"m",@"6",nil],
                                               [NSArray arrayWithObjects:@"/",@"7",nil],
                                               [NSArray arrayWithObjects:@" ",@"7",nil],
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
