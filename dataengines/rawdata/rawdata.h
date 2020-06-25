#ifndef RawData_H
#define RawData_H

#include "dataengineinterface.h"

#include <QVariantList>

#define RawData_iid "Mine.Plugin.RawData"

class RawData : public QObject, public DataEngineInterface
{
    Q_OBJECT
    Q_INTERFACES(DataEngineInterface)

    Q_PLUGIN_METADATA(IID RawData_iid)
public:
    explicit RawData();
    ~RawData();

    void ProcessingDatas(char *data, int count);
private:
    Frame *frame_;
};
#endif // RawData_H
