#ifndef JUSTFLOAT_H
#define JUSTFLOAT_H

#include "dataengineinterface.h"

#include <QVariantList>

#define JustFloat_iid "Mine.Plugin.JustFloat"

class JustFloat : public QObject, public DataEngineInterface
{
    Q_OBJECT
    Q_INTERFACES(DataEngineInterface)

    Q_PLUGIN_METADATA(IID JustFloat_iid)
public:
    explicit JustFloat();
    ~JustFloat();

    void ProcessingDatas(char *data, int count);
    bool ProcessingFrame(char *data, int count, QVector<float> &dd);
private:
    uint32_t image_count_mutation_count_ = 0;
};
#endif // JUSTFLOAT_H
