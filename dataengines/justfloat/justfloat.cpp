#include "justfloat.h"
#include <QDebug>
#include <limits>


JustFloat::JustFloat()
{

}

JustFloat::~JustFloat()
{

}


QVariantList JustFloat::ProcessingFrame(QByteArray frame)
{
    QVariantList dd;

    if (frame.size() <= 0) {
        return QVariantList();
    }

    if (frame.size() % 4 == 0) {
        double max = std::numeric_limits<double>::min();
        double min = std::numeric_limits<double>::max();
        for (int i = 0; i < frame.length() - 4; i += 4) {
//            double value = datas[i].trimmed().toDouble();
            double value = (double)(*((float*)&frame.data()[i]));
            if (value > max)
                max = value;
            if (value < min)
                min = value;
            dd.append(value);
        }
        QVariantList max_min;
        max_min.append(max);
        max_min.append(min);
        dd.append(static_cast<QVariant>(max_min));
        if (!hide_data_packets())
            processed_datas_.append(frame);
    } else {
        processed_datas_.append(frame);
    }
    return dd;
}

QVariantList JustFloat::ProcessingDatas(const QByteArray data)
{
    QVariantList datas_;

    unprocessed_datas_.append(data);
    int begin = 0;
    for (int i = 3; i < unprocessed_datas_.length(); i++) {
        int d = *((int *)(&unprocessed_datas_.data()[i - 3]));
        if (d == (int)0x7F800000) {
            QByteArray tmp = unprocessed_datas_.mid(begin, (i - begin) + 1);
            QVariant d = ProcessingFrame(tmp);
            if (d.toList().length() > 0) {
                datas_.append(d);
            }
            begin = i+1;
        }
    }
    unprocessed_datas_ = unprocessed_datas_.mid(begin);

    return datas_;
}

QByteArray JustFloat::ProcessedDatas()
{
    return processed_datas_;
}


void JustFloat::ClearProcessedDatas()
{
    processed_datas_.clear();
}

