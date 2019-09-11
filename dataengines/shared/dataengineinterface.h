#ifndef DATAENGINEINTERFACE_H
#define DATAENGINEINTERFACE_H

#include <QVariantList>
#include <QtCore>

class RawImage {
public:
    RawImage() {;}
    enum Format {
        Format_Invalid,
        Format_Mono,
        Format_MonoLSB,
        Format_Indexed8,
        Format_RGB32,
        Format_ARGB32,
        Format_ARGB32_Premultiplied,
        Format_RGB16,
        Format_ARGB8565_Premultiplied,
        Format_RGB666,
        Format_ARGB6666_Premultiplied,
        Format_RGB555,
        Format_ARGB8555_Premultiplied,
        Format_RGB888,
        Format_RGB444,
        Format_ARGB4444_Premultiplied,
        Format_RGBX8888,
        Format_RGBA8888,
        Format_RGBA8888_Premultiplied,
        Format_BGR30,
        Format_A2BGR30_Premultiplied,
        Format_RGB30,
        Format_A2RGB30_Premultiplied,
        Format_Alpha8,
        Format_Grayscale8,
        Format_BMP,
        Format_GIF,
        Format_JPG,
        Format_PNG,
        Format_PBM,
        Format_PGM,
        Format_PPM,
        Format_XBM,
        Format_XPM,
        Format_SVG,
    };
    void set(uchar *data, int len, int width, int height, Format format) {
        data_.resize(len);
        memcpy(data_.data(), data, len);
        length_ = len;
        format_ = format;
        width_ = width;
        height_ = height;
    }
    uchar *data() { return data_.data(); }
    int length() { return length_; }
    int width() { return width_; }
    int height() { return height_; }
    Format format() { return format_; }
private:
//    uchar *data_;
    QVector<uchar> data_;
    Format format_;
    int length_ = 0;
    int width_ = 0;
    int height_= 0;
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
