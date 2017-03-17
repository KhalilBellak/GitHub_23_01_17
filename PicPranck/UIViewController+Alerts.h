//
//  UIViewController+Alerts.h
//  PicPranck
//
//  Created by El Khalil Bellakrid on 16/03/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/*! @typedef AlertPromptCompletionBlock
 @brief The type of callback used to report text input prompt results.
 */
typedef void (^AlertPromptCompletionBlock)(BOOL userPressedOK, NSString *_Nullable userInput);

@interface UIViewController (Alerts)

/*! @fn showMessagePrompt:
 @brief Displays an alert with an 'OK' button and a message.
 @param message The message to display.
 */
- (void)showMessagePrompt:(NSString *)message;

/*! @fn showTextInputPromptWithMessage:completionBlock:
 @brief Shows a prompt with a text field and 'OK'/'Cancel' buttons.
 @param message The message to display.
 @param completion A block to call when the user taps 'OK' or 'Cancel'.
 */
- (void)showTextInputPromptWithMessage:(NSString *)message
                       completionBlock:(AlertPromptCompletionBlock)completion;

/*! @fn showSpinner
 @brief Shows the please wait spinner.
 @param completion Called after the spinner has been hidden.
 */
- (void)showSpinner:(nullable void (^)(void))completion;

/*! @fn hideSpinner
 @brief Hides the please wait spinner.
 @param completion Called after the spinner has been hidden.
 */
- (void)hideSpinner:(nullable void (^)(void))completion;


@end
NS_ASSUME_NONNULL_END
