function connections = findHierarchy(allregions,sulabel)
        for k = 1: length(allregions{2})   %超像素个数
            index_1 = allregions{2}{k}.pixelInd;  %较大超像素包含的像素索引
            temp = unique(sulabel{1}(index_1));  %大超像素位置上对应的相邻尺度的小超像素
            oriconnections = [];
            for m = 1:length(temp)
                index_2 = allregions{1}{temp(m)}; %较小超像素对应的像素索引
                PixNum_1 = length(intersect(index_1,index_2));  %大小超像素的交集
                PixNum_2 = length(allregions{1}{temp(m)});  %小超像素的像素个数
                if PixNum_1/PixNum_2 > 0.5
                    oriconnections = [oriconnections;temp(m)];
                end
            end
            connections(k) = {oriconnections};
        end
     
 


