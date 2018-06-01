function adjMatrix = GetAdjMatrix(idxImg, spNum)
% Get adjacent matrix of super-pixels
% idxImg is an integer image, values in [1..spNum]

% Code Author: Wangjiang Zhu
% Email: wangjiang88119@gmail.com
% Date: 3/24/2014

[h, w] = size(idxImg);

%Get edge pixel locations (4-neighbor)  找出各个超像素交界上的像素
topbotDiff = diff(idxImg, 1, 1) ~= 0;      %将矩阵的后一行减去前一行，所得矩阵中不为0的元素即为1
topEdgeIdx = find( padarray(topbotDiff, [1 0], false, 'post') ); %those pixels on the top of an edge   padarray:填充图像或填充数组
botEdgeIdx = topEdgeIdx + 1;

leftrightDiff = diff(idxImg, 1, 2) ~= 0;   %将矩阵的后一列减去前一列
leftEdgeIdx = find( padarray(leftrightDiff, [0 1], false, 'post') ); %those pixels on the left of an edge
rightEdgeIdx = leftEdgeIdx + h;

%Get adjacent matrix of super-pixels
adjMatrix = zeros(spNum, spNum);
adjMatrix( sub2ind([spNum, spNum], idxImg(topEdgeIdx), idxImg(botEdgeIdx)) ) = 1;
adjMatrix( sub2ind([spNum, spNum], idxImg(leftEdgeIdx), idxImg(rightEdgeIdx)) ) = 1;
adjMatrix = adjMatrix + adjMatrix';
adjMatrix(1:spNum+1:end) = 1;%set diagonal elements to 1
adjMatrix = sparse(adjMatrix);