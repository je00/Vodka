#ifndef DATAENGINEINTERFACE_H
#define DATAENGINEINTERFACE_H

#include <QVariantList>
#include <QtCore>

class DataEngineInterface
{

public:
    ~DataEngineInterface() {}
//    virtual QVariantList ProcessingDatas(const QByteArray data) = 0;
    virtual void ProcessingDatas(char *data, int count) = 0;

    bool hide_data_packets() { return hide_data_packets_; }
    void set_hide_data_packets(bool value) { hide_data_packets_ = value; }

    QVector<int> frame_start_index_list() { return frame_start_index_list_; }
    QVector<int> frame_end_index_list() { return frame_end_index_list_; }
    QVector<QVector<float>> frame_datas_list() { return frame_datas_list_; }

protected:
    bool hide_data_packets_;
    QVector<int> frame_start_index_list_;
    QVector<int> frame_end_index_list_;
    QVector<QVector<float>> frame_datas_list_;
};


#define DataEngineInterface_iid "Mine.Plugin.DataEngineInterface"

QT_BEGIN_NAMESPACE
Q_DECLARE_INTERFACE(DataEngineInterface, DataEngineInterface_iid)
QT_END_NAMESPACE

#endif // DATAENGINEINTERFACE_H
