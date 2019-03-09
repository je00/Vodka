#include "RawData.h"
#include <QDebug>
#include <limits>


RawData::RawData()
{

}

RawData::~RawData()
{

}


QVariantList RawData::ProcessingDatas(const QByteArray data)
{
    QVariantList datas_;

    processed_datas_.append(data);

    return QVariantList();
}

QByteArray RawData::ProcessedDatas()
{
    return processed_datas_;
}


void RawData::ClearProcessedDatas()
{
    processed_datas_.clear();
}

