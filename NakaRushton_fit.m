function [NRF_parameters, nkrFun] = NakaRushton_fit(R, I, initial_params)
%NAKARUSHTON_FIT The NR function is a model used to describe the
%relationship between stimulus intensity (I) and perceptual response (R),
%especially in cases where the response shows compressive non-linearity. 
% For this maximum likelihood parameter estimation, I'm using a negative log-likelihood
% function (nll) minimize w.r.t. the parameters (R_max, sigma, n) and the
% fminsearch algorithm. The output is the MLE estimates for the NRfunction
% parameters. 

% INPUTS:
    % R : this is the vector of perceptual responses for the tested
        % stimulus intensities.
    % I : intensity of the stimulus 
    % initial_params: this should be a 1x3 vector with initial estimates
        % for the following paramters: 
            % R_max : maximum attainable response or asymptote
            % n : exponential parameter that controls the steepness of the
                % function
            % sigma : the semi-saturation constant, or parameter that sets the
                % threshold between stimulus values for responses halfway between
                % minimum and maximum values
% OUTPUTS:
    % NRF_parameters : The output is the MLE estimates for the NRfunction
        % parameters based on a negative log-likelihood minimization approach
    % nkrFun : the Naka-Rushton function that can be used to model
        % responses with the output parameters
        
% VScerra 2023

% Define the Naka-Rushton function
nkrFun =  @(params,I) params(1) * (I.^params(2)) ./ (I.^params(2) + params(3).^params(2));
% Initialize parameters
if nargin < 3
    initial_R_max = 1;
    initial_n = 0.7;
    initial_sigma = .10;
    initial_params = [initial_R_max, initial_n, initial_sigma]; % Initial parameter values
end

% Define negative log-likelihood function
nll_func = @(params) -sum(log(normpdf(R, params(1) * (I.^params(2)) ./ (I.^params(2) + params(3).^params(2)), params(3))));

% Perform optimization
opts = optimset('MaxFunEvals', 100000, 'MaxIter', 100000);
NRF_parameters = fminsearch(nll_func, initial_params,opts);
end

