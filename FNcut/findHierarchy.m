function connections = findHierarchy(allregions,sulabel)
        for k = 1: length(allregions{2})   %�����ظ���
            index_1 = allregions{2}{k}.pixelInd;  %�ϴ����ذ�������������
            temp = unique(sulabel{1}(index_1));  %������λ���϶�Ӧ�����ڳ߶ȵ�С������
            oriconnections = [];
            for m = 1:length(temp)
                index_2 = allregions{1}{temp(m)}; %��С�����ض�Ӧ����������
                PixNum_1 = length(intersect(index_1,index_2));  %��С�����صĽ���
                PixNum_2 = length(allregions{1}{temp(m)});  %С�����ص����ظ���
                if PixNum_1/PixNum_2 > 0.5
                    oriconnections = [oriconnections;temp(m)];
                end
            end
            connections(k) = {oriconnections};
        end
     
 


