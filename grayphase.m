% initial variables
t = cputime;
flat_calib; % load calibration data
addpath('./utilities'); % for converting gray codes
rat_dir = './hump/';
period = 684.0/64; % determined from phase-shifted images...
minContrast = .2;
downSample = 20;


%% read in images
scans = cell(1,10);
for i=0:9
    temp = imread([rat_dir,int2str(i),'.jpg']);
    scans{i+1} = rgb2gray(temp);
end

texture = imread([rat_dir,'texture.jpg']);
height = size(texture,1); % num rows = 480
width = size(texture,2); % num cols = 640

%% obtain gray codes
G = zeros(height,width,6);
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
% for i=1:66
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
mask = find(intensity < 0);
intensity(mask) = intensity(mask) + 2*pi;              
phase = intensity;

idx = 1:200:height*width;
pts = phase(idx);
% scatter(pts, sin(pts));
% pause;

% obtain row correspondences for each pixel
rows = 2*pi * (section-1) + phase;
idx = 1:10:height*width;
pts = rows(idx);
% scatter(pts, sin(pts))
% 
% break;

rows = rows * period / (2*pi); % is period correct?

% suspicious: why do I never get 684 as the max row value?

%% triangulate
rows = rows(:)';
numPoints = height*width;
[x,y] = ind2sub(size(texture),[1:numPoints]);
points = [y;x]; % as in (x,y)'
pad = ones(1,numPoints);

cam_rays = [points; fLength_cam*pad]; %construct camera rays

p1 = [(2-T(1))*pad; rows-T(2); (fLength_proj-T(3))*pad]; %use any x coordinate
p2 = [(12-T(1))*pad; rows-T(2); (fLength_proj-T(3))*pad]; % PE: +T?
planes = R*cross(p1,p2); %origin is T

numerator = dot(planes, [T(1)*pad;T(2)*pad;T(3)*pad]);
denominator = dot(planes, cam_rays);
lambda = numerator ./ denominator;

cloud = zeros(numPoints,3);
for i=1:3
    cloud(:,i) = lambda .* cam_rays(i,:);
end

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





