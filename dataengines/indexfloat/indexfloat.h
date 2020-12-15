#ifndef INDEXFLOAT_H
#define INDEXFLOAT_H

#include "dataengineinterface.h"

class IndexFloat : public QObject, public DataEngineInterface
{
    Q_OBJECT
    Q_INTERFACES(DataEngineInterface)
    Q_PLUGIN_METADATA(IID "VOFA+.Plugin.IndexFloat")

public:
    explicit IndexFloat();
    ~IndexFloat();

    void ProcessingDatas(char *data, int count);
    bool ProcessingFrame(char *data, int count, QVector<float> &dd);
private:
    uint32_t image_count_mutation_count_ = 0;
    QVector<float> buf_;
};
#endif // IndexFloat_H
