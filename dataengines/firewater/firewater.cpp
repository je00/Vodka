#include "firewater.h"
#include <QDebug>
#include <limits>


FireWater::FireWater()
{

}

FireWater::~FireWater()
{

}


QVariantList FireWater::ProcessingFrame(QByteArray frame)
{
    QVariantList dd;

    QString data = frame.trimmed();
    if (data.size() <= 0) {
        return QVariantList();
    }

    QList<QString> nameNdata = data.split(':');

    if (nameNdata.size() == 2) {
        QString name =  nameNdata[0].trimmed();
        QList<QString> datas = nameNdata[1].split(',');
        double max = std::numeric_limits<double>::min();
        double min = std::numeric_limits<double>::max();
        for (int i = 0; i < datas.length(); i++) {
            double value = datas[i].trimmed().toDouble();
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


QVariantList FireWater::ProcessingDatas(const QByteArray data)
{
    QVariantList datas_;

    unprocessed_datas_.append(data);
//    qDebug() << data;
    int begin = 0;
    for (int i = 0; i < unprocessed_datas_.length(); i++) {
        if (unprocessed_datas_.at(i) == '\n') {
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


QByteArray FireWater::ProcessedDatas()
{
    return processed_datas_;
}


void FireWater::ClearProcessedDatas()
{
    processed_datas_.clear();
}

