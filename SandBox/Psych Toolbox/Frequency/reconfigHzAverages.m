for i = 1:30
    average(i) = 1/mean(actualhz(i,:)) - i;
    average2(i) = 1/mean(abs(actualhz2(i,:))) - i;
    
end
plot(average)
hold on 
plot(average2)
legend('Inefficient','Efficient')