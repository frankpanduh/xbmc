/*
 *  Copyright (C) 2012-2018 Team Kodi
 *  This file is part of Kodi - https://kodi.tv
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 *  See LICENSES/README.md for more information.
 */

#ifdef (TARGET_DARWIN_IOS)
#include "XBMCController.h"
#endif
#import "platform/darwin/NSLogDebugHelpers.h"
#include "platform/darwin/DarwinUtils.h"
#include "platform/darwin/ios-common/IOSKeyboard.h"
#include "platform/darwin/ios-common/IOSKeyboardView.h"


#import "platform/darwin/AutoPool.h"

KeyboardView *g_pIosKeyboard = nil;

bool CIOSKeyboard::ShowAndGetInput(char_callback_t pCallback, const std::string &initialString, std::string &typedString, const std::string &heading, bool bHiddenInput)
{
  // we are in the MCRuntimeLib thread so we need a pool
  CCocoaAutoPool pool;

  @synchronized([KeyboardView class])
  {
    // in case twice open keyboard.
    if (g_pIosKeyboard)
      return false;

    // assume we are only drawn on the mainscreen ever!
    UIScreen* pCurrentScreen = [UIScreen mainScreen];
    CGRect keyboardFrame = CGRectMake(0, 0, pCurrentScreen.bounds.size.height, pCurrentScreen.bounds.size.width);
//    LOG(@"kb: kb frame: %@", NSStringFromCGRect(keyboardFrame));

    //create the keyboardview
    g_pIosKeyboard = [[KeyboardView alloc] initWithFrame:keyboardFrame];
    if (!g_pIosKeyboard)
      return false;

#ifdef (TARGET_DARWIN_IOS)
    // inform the controller that the native keyboard is active
    // basically as long as g_pIosKeyboard exists...
    [g_xbmcController nativeKeyboardActive:true];
#endif
  }

  m_pCharCallback = pCallback;

  // init keyboard stuff
  SetTextToKeyboard(initialString);
  [g_pIosKeyboard setHidden:bHiddenInput];
  [g_pIosKeyboard setHeading:[NSString stringWithUTF8String:heading.c_str()]];
  [g_pIosKeyboard registerKeyboard:this]; // for calling back
  bool confirmed = false;
  if (!m_bCanceled)
  {
    [g_pIosKeyboard setCancelFlag:&m_bCanceled];
    [g_pIosKeyboard activate]; // blocks and shows keyboard
    // user is done - get resulted text and confirmation
    confirmed = g_pIosKeyboard.isConfirmed;
    if (confirmed)
      typedString = [g_pIosKeyboard._text UTF8String];
  }
  [g_pIosKeyboard release]; // bye bye native keyboard
  @synchronized([KeyboardView class])
  {
    g_pIosKeyboard = nil;

#ifdef (TARGET_DARWIN_IOS)
    [g_xbmcController nativeKeyboardActive:false];
#endif
  }
  return confirmed;
}

void CIOSKeyboard::Cancel()
{
  m_bCanceled = true;
}

bool CIOSKeyboard::SetTextToKeyboard(const std::string &text, bool closeKeyboard /* = false */)
{
  if (!g_pIosKeyboard)
    return false;
  [g_pIosKeyboard setKeyboardText:[NSString stringWithUTF8String:text.c_str()] closeKeyboard:closeKeyboard?YES:NO];
  return true;
}

//wrap our callback between objc and c++
void CIOSKeyboard::fireCallback(const std::string &str)
{
  if(m_pCharCallback)
  {
    m_pCharCallback(this, str);
  }
}
