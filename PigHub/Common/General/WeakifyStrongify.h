//
//  Macros.h
//  PigHub
//
//  Created by Rainbow on 2017/1/6.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#ifndef WeakifyStrongify_h
#define WeakifyStrongify_h


// weakify and strongify   http://holko.pl/2015/05/31/weakify-strongify/
#define weakify(var) __weak typeof(var) AHKWeak_##var = var;
#define strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = AHKWeak_##var; \
_Pragma("clang diagnostic pop")

#endif /* WeakifyStrongify_h */
