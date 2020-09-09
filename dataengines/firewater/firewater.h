#ifndef FIREWATER_H
#define FIREWATER_H

#include "dataengineinterface.h"

class FireWater : public QObject, public DataEngineInterface
{
    Q_OBJECT
    Q_INTERFACES(DataEngineInterface)
    Q_PLUGIN_METADATA(IID "VOFA+.Plugin.FireWater")

public:
    explicit FireWater();
    ~FireWater();
    void ProcessingDatas(char *data, int count);
private:
    uint32_t image_count_mutation_count_ = 0;
};
#endif // FIREWATER_H
