#ifndef DATAENGINEINTERFACE_H
#define DATAENGINEINTERFACE_H

#include <QVariantList>
#include <QtCore>

class RawImage {
public:
    RawImage() {;}
    void set(uchar *data, int len, QString format) {
        data_.resize(len);
        memcpy(data_.data(), data, len);
        length_ = len;
        format_ = format;
    }
    uchar *data() { return data_.data(); }
    int length() { return length_; }
    QString format() { return format_; }
private:
//    uchar *data_;
    QVector<uchar> data_;
    QString format_;
    int length_ = 0;
};

class DataEngineInterface
{

public:
    ~DataEngineInterface() {}
//    virtual QVariantList ProcessingDatas(const QByteArray data) = 0;
    virtual void ProcessingDatas(char *data, int count) = 0;

    QVector<int> frame_start_index_list() {
//        image_.size();
        return frame_start_index_list_; }
    QVector<int> frame_end_index_list() { return frame_end_index_list_; }
    QVector<bool> frame_is_valid_list() { return frame_is_valid_list_; }
    QVector<QVector<float>> frame_datas_list() { return frame_datas_list_; }

    QVector<RawImage*> image_list() { return image_list_; }
    QVector<bool> image_updated_list() { return image_is_updated_list_; }
    QVector<int> frame_image_size_list() { return frame_image_size_list_; }

protected:
    QVector<int> frame_start_index_list_;
    QVector<int> frame_end_index_list_;
    QVector<bool> frame_is_valid_list_;
    QVector<int> frame_image_size_list_;
    QVector<QVector<float>> frame_datas_list_;
    QVector<RawImage*> image_list_;
    QVector<bool> image_is_updated_list_;
};


#define DataEngineInterface_iid "Mine.Plugin.DataEngineInterface"

QT_BEGIN_NAMESPACE
Q_DECLARE_INTERFACE(DataEngineInterface, DataEngineInterface_iid)
QT_END_NAMESPACE

#endif // DATAENGINEINTERFACE_H
