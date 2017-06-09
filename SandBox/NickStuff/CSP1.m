traindata = exp_eval(io_loadset('C:\Users\gsteelman\Desktop\bob1.gdf','channels',1:4));
brains = [traindata.data(2,:);traindata.data(3,:)]
X1 = []
X2 = []
srate = 220
offset = 3
endset = 15
for i = 1 : length(traindata.event)
    if(strcmp(traindata.event(i).type, '68'))
        marker = traindata.event(i).latency;
        X1 = [X1; brains(:,marker + srate * offset:marker + srate * endset).'];
        disp('1')
    elseif(strcmp(traindata.event(i).type, '69'))
        marker = traindata.event(i).latency;
        X2 = [X2; brains(:,marker + srate * offset:marker + srate * endset).'];
        disp('2')
    end
end
%{
X1 = double(brains.cnt(1:9980,1:2)).';
X2 = double(brains.cnt(3000:4000,1:2)).';
data_open = importdata('data_open.mat')
data_closed = importdata('data_closed.mat')
X1 = data_open;
X2 = data_closed;
%}
X1 = X1.'
X2 = X2.'
coeffs = polyfit(X1(1,:), X1(2,:), 1)
% Get fitted values
coeffs1 = polyfit(X2(1,:), X2(2,:), 1)
mymat = [coeffs(1) -1 ; coeffs1(1) -1]
% Get fitted values
mymat = inv(mymat)
intersection = mymat * [-coeffs(2) ;-coeffs1(2)]
X1(1,:) = X1(1,:)- intersection(1)
X1(2,:) = X1(2,:)- intersection(2)
X2(1,:) = X2(1,:)- intersection(1)
X2(2,:) = X2(2,:)- intersection(2)
%{
x = linspace(-3,3,1000)
%xa = awgn(linspace(-.1,.1,1000),8)
y = awgn(x .* 1,.3)
z = awgn(x .* 3,.3)
%x = x .* x
%y = y .* y
%x1 = x1 .* x1
%z = z .* z

X1 = [x ;y]
X2 = [x ;z]
%}
R1 = (X1*X1.')/trace(X1*X1.');
R2 = (X2*X2.')/trace(X2*X2.');


R = R1 + R2;


[U1, D1] = eig(R1);

[U2, D2] = eig(R2);

[U0, D0] = eig(R);
D1
D2
D0
for i=1:length(D0)
    D0(i,i) = D0(i,i).^(-1/2);
end
D0
P = D0 * U0.';

S1 = P* R1*P.';
S2 = P* R2 *P.';

[U1, D1] = eig(S1);
[U2, D2] = eig(S2);
I = D1 + D2;
%Check that U1 = U2 and D1 + D2 = I
I
U1
U2
W = U2.'*P;
Z1 = W*X1;
Z2 = W*X2;
Z1 = Z1 .^2;
Z2 = Z2 .^2;
A1=[]
A2=[]
for i = 1:50:length(Z1(1,:))-101
    A1 = [A1;mean(Z1(1,i:i+100)) mean(Z1(2,i:i+100))];
    A2 = [A2;mean(Z2(1,i:i+100)) mean(Z2(2,i:i+100))];
    
    
    
end
hold on
scatter(X2(1,:), X2(2,:),'filled')
scatter(X1(1,:), X1(2,:),'filled')


figure
hold on
A1 = A1.'
A2 = A2.'
scatter(A2(1,:), A2(2,:),'filled')
scatter(A1(1,:), A1(2,:),'filled')

%scatter(Z2(1,:), Z2(2,:),'filled')
%scatter(Z1(1,:), Z1(2,:),'filled')

legend('class1','class2')
xlabel('Channel 1 Value')
ylabel('Channel 2 Value')
title('Sample Training Data, Post CSP')