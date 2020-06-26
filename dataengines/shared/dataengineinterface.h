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
        updated_ = true;
    }
    uchar *data() { return data_.data(); }
    int length() { return length_; }
    int width() { return width_; }
    int height() { return height_; }
    Format format() { return format_; }
    bool updated() { return updated_; }
private:
//    uchar *data_;
    QVector<uchar> data_;
    Format format_;
    int length_ = 0;
    int width_ = 0;
    int height_= 0;
    bool updated_ = true;
};


struct Frame {
    int start_index_ = 0;
    int end_index_ = 0;
    int image_size_ = 0;
    QVector<float> datas_;
    bool is_valid_ = 0;
};

class DataEngineInterface
{

public:
    ~DataEngineInterface() {}
    virtual void ProcessingDatas(char *data, int count) = 0;

    const QList<Frame> &frame_list() { return frame_list_; }
    const QList<RawImage*> &image_channels() { return image_channels_; }

protected:
    QList<Frame> frame_list_;
    QList<RawImage*> image_channels_;
};


#define DataEngineInterface_iid "VOFA+.Plugin.DataEngineInterface"

QT_BEGIN_NAMESPACE
Q_DECLARE_INTERFACE(DataEngineInterface, DataEngineInterface_iid)
QT_END_NAMESPACE

#endif // DATAENGINEINTERFACE_H
