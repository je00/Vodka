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

    QVariantList ProcessingDatas(const QByteArray data);
    QByteArray ProcessedDatas();
    void ClearProcessedDatas();

    QVariantList ProcessingFrame(QByteArray frame);

private:
    QByteArray unprocessed_datas_;
    QByteArray processed_datas_;
};
#endif // FIREWATER_H
