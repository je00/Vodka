#ifndef FIREWATER_H
#define FIREWATER_H

#include "dataengineinterface.h"

#include <QVariantList>

#define FireWater_iid "Mine.Plugin.FireWater"

class FireWater : public QObject, public DataEngineInterface
{
    Q_OBJECT
    Q_INTERFACES(DataEngineInterface)

    Q_PLUGIN_METADATA(IID FireWater_iid)
public:
    explicit FireWater();
    ~FireWater();
    void ProcessingDatas(char *data, int count);
    bool ProcessingFrame(char *data, int count);
};
#endif // FIREWATER_H
