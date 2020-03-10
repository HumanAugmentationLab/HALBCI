function [model] = SamSpecCSP(signal,n_of,pp,qp,prior,steps,X)
%
%             args = arg_define(varargin, ...
%                 arg_norep('signal'), ...
%                 arg({'patterns','PatternPairs'},3,uint32([1 1 64 1000]),'Number of CSP patterns (times two).','cat','Feature Extraction'), ...
%                 arg({'pp','ParameterP'},0,[-1 1],'Regularization parameter p''. Can be searched over -1:0.5:1.','cat','Feature Extraction','guru',true), ...
%                 arg({'qp','ParameterQ'},1,[0 4],'Regularization parameter q''. Can be searched over 0:0.5:4.','cat','Feature Extraction','guru',true), ...
%                 arg({'prior','SpectralPrior'},'@(f) f>=7 & f<=30',[],'Prior frequency weighting function.','cat','Feature Extraction', 'type','expression'), ...
%                 arg({'steps','MaxIterations'},3,uint32([1 3 10 50]),'Number of iterations. A step is spatial optimization, followed by spectral optimization.','cat','Feature Extraction'));
%         
       
% read a few parameters from the options (and re-parameterize the hyper-parameters p' and q' into p and q)
            p = pp+qp;
            q = qp;
            if isnumeric(prior) && length(prior) == 2
                prior = @(f) f >= prior(1) & f <= prior(2); end
            % number of C=Channels, S=Samples and T=Trials #ok<NASGU>
            [C,S,dum] = size(signal.data); %#ok<NASGU>
            % build a frequency table (one per DFT bin)
            freqs = (0:S-1)*signal.srate/S;
            % evaluate the prior I
            I = prior(freqs);
            % and find table indices that are supported by the prior
            bands = find(I);
            
            marker_values = str2double(cell2mat({signal.epoch.eventtype}'));
            
            
            % preprocessing
            for c=1:2
                % compute the per-class epoched data X and its Fourier transform (along time), Xfft
%                X{c} = exp_eval_optimized(set_picktrials(signal,'rank',c));
                [C,S,T] = size(X{c}.data);
                Xfft{c} = fft(X{c}.data,[],2);
                % the full spectrum F of covariance matrices per every DFT bin and trial of the data
                F{c} = single(zeros(C,C,max(bands),T));
                for k=bands
                    for t=1:T
                        F{c}(:,:,k,t) = 2*real(Xfft{c}(:,k,t)*Xfft{c}(:,k,t)'); end
                end
                % compute the cross-spectrum V as an average over trials
                V{c} = mean(F{c},4);
            end
            
            % 1. initialize the filter set alpha and the number of filters J
            J = 1; alpha{J}(bands) = 1;
            % 2. for each step
            for step=1:steps
                % 3. for each set of spectral coefficients alpha{j} (j=1,...,J)
                for j=1:J
                    % 4. calculate sensor covariance matrices for each class from alpha{j}
                    for c = 1:2
                        Sigma{c} = zeros(C);
                        for b=bands
                            Sigma{c} = Sigma{c} + alpha{j}(b)*V{c}(:,:,b); end
                    end
                    % 5. solve the generalized eigenvalue problem Eq. (2)
                    [VV,DD] = eig(Sigma{1},Sigma{1}+Sigma{2});
                    % and retain n_of top eigenvectors at both ends of the eigenvalue spectrum...
                    W{j} = {VV(:,1:n_of), VV(:,end-n_of+1:end)};
                    iVV = inv(VV)'; P{j} = {iVV(:,1:n_of), iVV(:,end-n_of+1:end)};
                    % as well as the top eigenvalue for each class
                    lambda(j,:) = [DD(1), DD(end)];
                end
                % 7. set W{c} from all W{j}{c} such that lambda(j,c) is minimal/maximal over j
                W = {W{argmin(lambda(:,1))}{1}, W{argmax(lambda(:,2))}{2}};
                P = {P{argmin(lambda(:,1))}{1}, P{argmax(lambda(:,2))}{2}};
                % 8. for each projection w in the concatenated [W{1},W{2}]...
                Wcat = [W{1} W{2}]; J = 2*n_of;
                Pcat = [P{1} P{2}];
                for j=1:J
                    w = Wcat(:,j);
                    % 9. calcualate (across trials within each class) mean and variance of the w-projected cross-spectrum components
                    for c=1:2
                        % part of Eq. (3)
                        s{c} = zeros(size(F{c},4),max(bands));
                        for k=bands
                            for t = 1:size(s{c},1)
                                s{c}(t,k) = w'*F{c}(:,:,k,t)*w; end
                        end
                        mu_s{c} = mean(s{c},1);
                        var_s{c} = var(s{c},0,1);
                    end
                    % 10. update alpha{j} according to Eqs. (4) and (5)
                    for c=1:2
                        for k=bands
                            % Eq. (4)
                            alpha_opt{c}(k) = max(0, (mu_s{c}(k)-mu_s{3-c}(k)) / (var_s{1}(k) + var_s{2}(k)) );
                            % Eq. (5), with prior from Eq. (6)
                            alpha_tmp{c}(k) = alpha_opt{c}(k).^q * (I(k) * (mu_s{1}(k) + mu_s{2}(k))/2).^p;
                        end
                    end
                    % ... as the maximum for both classes
                    alpha{j} = max(alpha_tmp{1},alpha_tmp{2});
                    % and normalize alpha{j} so that it sums to unity
                    alpha{j} = alpha{j} / sum(alpha{j});
                end
            end
            alpha = [vertcat(alpha{:})'; zeros(S-length(alpha{1}),length(alpha))];
            model = struct('W',{Wcat},'P',{Pcat},'alpha',{alpha},'freqs',{freqs},'bands',{bands},'chanlocs',{signal.chanlocs});            
        end
%         
%         function features = feature_extract(self,signal,featuremodel)
%             features = zeros(size(signal.data,3),size(featuremodel.W,2));
%             for t=1:size(signal.data,3)
%                 features(t,:) = log(var(2*real(ifft(featuremodel.alpha.*fft(signal.data(:,:,t)'*featuremodel.W))))); end                
%         end
%         
%         function visualize_model(self,varargin) %#ok<*INUSD>
%             args = arg_define([0 3],varargin, ...
%                 arg_norep({'myparent','Parent'},[],[],'Parent figure.'), ...
%                 arg_norep({'featuremodel','FeatureModel'},[],[],'Feature model. This is the part of the model that describes the feature extraction.'), ...
%                 arg_norep({'predictivemodel','PredictiveModel'},[],[],'Predictive model. This is the part of the model that describes the predictive mapping.'), ...
%                 arg({'patterns','PlotPatterns'},true,[],'Plot patterns instead of filters. Whether to plot spatial patterns (forward projections) rather than spatial filters.'), ...
%                 arg({'paper','PaperFigure'},false,[],'Use paper-style font sizes. Whether to generate a plot with font sizes etc. adjusted for paper.'), ...
%                 arg_nogui({'nosedir_override','NoseDirectionOverride'},'',{'','+X','+Y','-X','-Y'},'Override nose direction.'));
%             arg_toworkspace(args);
% 
%             % no parent: create new figure
%             if isempty(myparent)
%                 myparent = figure('Name','Common Spatial Patterns'); end
%             % determine nose direction for EEGLAB graphics
%             try
%                 nosedir = args.fmodel.signal.info.chaninfo.nosedir;
%             catch
%                 disp_once('Nose direction for plotting not store in model; assuming +X');
%                 nosedir = '+X';
%             end
%             if ~isempty(nosedir_override)
%                 nosedir = nosedir_override; end            
%             % number of pairs, and index of pattern per subplot
%             np = size(featuremodel.W,2)/2; idxp = [1:np np+(2*np:-1:np+1)]; idxf = [np+(1:np) 2*np+(2*np:-1:np+1)];
%             % for each CSP pattern...
%             for p=1:np*2
%                 subplot(4,np,idxp(p),'Parent',myparent);
%                 if args.patterns
%                     plotdata = featuremodel.P(:,p);
%                 else
%                     plotdata = featuremodel.W(:,p);
%                 end
%                 topoplot(plotdata,featuremodel.chanlocs,'nosedir',nosedir);
%                 subplot(4,np,idxf(p),'Parent',myparent);
%                 alpha = featuremodel.alpha(:,p);
%                 range = 1:max(find(alpha)); %#ok<MXFND>
%                 pl=plot(featuremodel.freqs(range),featuremodel.alpha(range,p));
%                 xlim([min(featuremodel.freqs(range)) max(featuremodel.freqs(range))]);
%                 l1 = xlabel('Frequency in Hz');
%                 l2 = ylabel('Weight');
%                 t=title(['Spec-CSP Pattern ' num2str(p)]);
%                 if args.paper
%                     set([gca,t,l1,l2],'FontUnits','normalized');
%                     set([gca,t,l1,l2],'FontSize',0.2);
%                     set(pl,'LineWidth',2);
%                 end
%             end    
%             try set(gcf,'Color',[1 1 1]); end
%         end
%         
%         function layout = dialog_layout_defaults(self)
%             layout = {'SignalProcessing.Resampling.SamplingRate', 'SignalProcessing.FIRFilter.Frequencies', ...
%                 'SignalProcessing.FIRFilter.Type', 'SignalProcessing.EpochExtraction', '', ...
%                 'Prediction.FeatureExtraction', '', ...
%                 'Prediction.MachineLearning.Learner'};
%         end
%         
%         function tf = needs_voting(self)
%             tf = true;
%         end        
        

%end

