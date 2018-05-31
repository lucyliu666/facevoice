% [x,y]=meshgrid([1:1024],[1:768]);
% x=abs(x-mean(x(:)));
% y=abs(y-mean(y(:)));
% s=sqrt([x.^2+y.^2]);


fix=zeros(768,1024);
fix(364:404,412:612)=1;
fix(284:484,492:532)=1;

