#ifndef RawData_H
#define RawData_H

#include "dataengineinterface.h"

class RawData : public QObject, public DataEngineInterface
{
    Q_OBJECT
    Q_INTERFACES(DataEngineInterface)
    Q_PLUGIN_METADATA(IID "VOFA+.Plugin.RawData")

public:
    explicit RawData();
    ~RawData();

    void ProcessingDatas(char *data, int count);
private:
    Frame *frame_;
};
#endif // RawData_H
