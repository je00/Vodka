#ifndef PRINTF_GLOBAL_H
#define PRINTF_GLOBAL_H

#include <QtCore/qglobal.h>

#if defined(PRINTF_LIBRARY)
#  define PRINTFSHARED_EXPORT Q_DECL_EXPORT
#else
#  define PRINTFSHARED_EXPORT Q_DECL_IMPORT
#endif

#endif // PRINTF_GLOBAL_H
