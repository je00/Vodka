#ifndef DATAENGINEINTERFACE_H
#define DATAENGINEINTERFACE_H

#include <QVariantList>
#include <QtCore>

class DataEngineInterface
{

public:
    ~DataEngineInterface() {}
    virtual QVariantList ProcessingDatas(const QByteArray data) = 0;
    virtual QByteArray ProcessedDatas() = 0;
    virtual void ClearProcessedDatas() = 0;

    bool hide_data_packets() { return hide_data_packets_; }
    void set_hide_data_packets(bool value) { hide_data_packets_ = value; }

private:
    bool hide_data_packets_;
};


#define DataEngineInterface_iid "Mine.Plugin.DataEngineInterface"

QT_BEGIN_NAMESPACE
Q_DECLARE_INTERFACE(DataEngineInterface, DataEngineInterface_iid)
QT_END_NAMESPACE

#endif // DATAENGINEINTERFACE_H
