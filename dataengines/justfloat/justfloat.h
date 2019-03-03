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

    QVariantList ProcessingDatas(const QByteArray data);
    QByteArray ProcessedDatas();
    void ClearProcessedDatas();

    QVariantList ProcessingFrame(QByteArray frame);

private:
    QByteArray unprocessed_datas_;
    QByteArray processed_datas_;
};
#endif // JUSTFLOAT_H
