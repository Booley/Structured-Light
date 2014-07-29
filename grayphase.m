% initial variables
t = cputime;
flat_calib; % load calibration data
addpath('./utilities'); % for converting gray codes
rat_dir = './Patterns/';
period = 684.0/64; % determined from phase-shifted images...but 480 rows / 64 sections...
minContrast = .2;
downSample = 1;


%% read in images
scans = cell(1,10);
for i=0:9
    temp = imread([rat_dir,'scan-',int2str(i),'.jpg']);
    scans{i+1} = rgb2gray(temp);
end

texture = imread([rat_dir,'texture.jpg']);
height = size(texture,1); % num rows = 480
width = size(texture,2); % num cols = 640

%% obtain gray codes
G = zeros(height,width,6);
imshow(texture);
avg = .5 * rgb2gray(texture);
avg = imadjust(avg); % change contrasting method to get clearer lines?
for i=1:6
    gray = imadjust(scans{i});
    % can insert mask-filtering here
    bitPlane = zeros(height,width);
    bitPlane(gray >= avg) = 1;
    G(:,:,i) = bitPlane; 
end

section = gray2dec(G);
% for i=1:64
%     disp(i);
%     colorSection = zeros(height, width);
%     colorSection(section == i) = 255;
%     imshow(colorSection);
%     pause;
% end
% break;

%% obtain phases by arctan(I4-I2/I3-I1)
% formula conflicts with sources...keep 0-2pi or -pi-pi????
intensity = atan2(double(scans{8}) - double(scans{10}), ...
                  double(scans{7}) - double(scans{9}));
% mask = find(intensity < 0);
% intensity(mask) = intensity(mask) + 2*pi;              
phase = intensity;

% idx = 1:10:684;
% pts = phase(idx,10);

% scatter(idx, (pts));
% axis([0 800 -2 2]);

% obtain row correspondences for each pixel
rows = 2*pi * (section) + phase; 

rows = rows * period / (2*pi); % is period correct?


%% triangulate
[x,y] = ind2sub(size(texture),[1:height*width]);
points = [y',x']'; % x,y ranges up to 640,480 (cols,rows)
numPoints = size(points,2);
rays = pixel2ray(points,fc,cc,kc,alpha); %now in camera coordinates


planes = getPlanes(rows,fy_proj,[0;0;0],R,T);
cloud = intersectLineWithPlane(zeros(size(rays)), rays, planes)';


%% get color, display
Rc        = im2double(texture(:,:,1));
Gc        = im2double(texture(:,:,2));
Bc        = im2double(texture(:,:,3));
colors = 0.65*ones(numPoints,3);
colors(:,1) = Rc(:);
colors(:,2) = Gc(:);
colors(:,3) = Bc(:);

C = reshape(colors,[size(colors,1) 1 size(colors,2)]);
[C,cmap] = rgb2ind(C,256);

% scatter3(cloud(1:downSample:end,1),...
%         cloud(1:downSample:end,3),...
%        -cloud(1:downSample:end,2));
% break;

fscatter3(cloud(1:downSample:end,1),...
        cloud(1:downSample:end,3),...
       -cloud(1:downSample:end,2),...
        double(C(1:downSample:end)),cmap);





