%% File Info.

%{

    model.m
    -------
    This code sets up the model.

%}

%% Model class.

classdef model
    methods(Static)
        %% Set up structure array for model parameters and set the simulation parameters.
        
        function par = setup()            
            %% Structure array for model parameters.
            
            par = struct();
            
            %% Labor market.

            par.J = 3; % Number of occupations.

            par.N_j = [0.2 0.4 0.4]; % Labor supply in occupation j.
            par.alpha_j = [0.95 0.8 0.8]; % Labor share of income.

            y_j = par.N_j.^(par.alpha_j); % Output in occupation j.
            mpl = par.alpha_j.*par.N_j.^(par.alpha_j-1);
            mpl(1) = mpl(1)*y_j(2)*y_j(3);
            mpl(2) = mpl(2)*y_j(1)*y_j(2);
            mpl(3) = mpl(3)*y_j(1)*y_j(2);

            par.w_j = mpl; % Wage rates are the marginal product of labor.

            par.elen = 10; % Number of income shock points in each occupation.
            par.sigma_eps = [0.07,0.35,0.78]; % Std. dev. of occupation shocks: safe, medium, and risky.

            par.kappa = [0.1, 0.005, -0.0001]; % Cost function parameters: intercept, linear coefficient, quadratic coefficient.

            par.lambda = 0.8; % Level shifter; higher values mean higher average tax rates.
            par.phi = 0.2; % Progressivity parameter; higher values mean more progressive.

            assert(par.J == 3.0,'Assume there are three occupations: safe, average, and risky.\n')
            assert(min(par.w_j) > 0.0,'Wages must be positive.\n')
            assert(min(par.N_j) > 0.0,'Population shares must be positive.\n')
            assert(sum(par.N_j) == 1,'Population shares must sum to one.\n')
            assert(max(par.alpha_j) < 1,'Production must be CRS.\n')
            assert(min(par.alpha_j) > 0,'Production must be CRS.\n')
            assert(par.lambda > 0.0 & par.lambda < 1.0,'Level shifter must be between 0 and 1.\n')
            assert(par.phi > 0.0 & par.phi < 1.0,'Progressivity must be between 0 and 1.\n')

            %% Preferences.

            par.T = 10; % Last period of life.
            
            par.beta = 0.96; % Discount factor: Lower values of this mean that consumers are impatient and consume more today.
            par.sigma = 2.0; % CRRA: Higher values of this mean that consumers are risk averse and do not want to consume too much today.
            
            assert(par.T > 0.0,'Age must be a positive integer.\n')
            assert(par.beta > 0.0 && par.beta < 1.0,'Discount factor should be between 0 and 1.\n')
            assert(par.sigma > 0.0,'CRRA should be at least 0.\n')

            %% Simulation parameters.

            par.seed = 2025; % Seed for simulation.
            par.TT = par.T; % Number of time periods.
            par.NN = 10000; % Number of people.

        end
        
        %% Generate state grids.
        
        function par = gen_grids(par)

            %% Distribution of income shocks for safe occupation.

            [eps1,w_eps1] = model.ghermite(par.elen);
            
            eps_s = exp(eps1.*(sqrt(2)*par.sigma_eps(1))); 
            prob_eps_s = w_eps1./sqrt(pi);

            %% Distribution of income shocks for medium occupation.

            [eps2,w_eps2] = model.ghermite(par.elen);
            
            eps_m = exp(eps2.*(sqrt(2)*par.sigma_eps(2))); 
            prob_eps_m = w_eps2./sqrt(pi);

            %% Distribution of income shocks for risky occupation.

            [eps3,w_eps3] = model.ghermite(par.elen);
            
            eps_r = exp(eps3.*(sqrt(2)*par.sigma_eps(3))); 
            prob_eps_r = w_eps3./sqrt(pi);

            %% Matrix of talent.

            par.eshock = [eps_s'; eps_m'; eps_r'];
            par.prob_eshock = [prob_eps_s'; prob_eps_m'; prob_eps_r'];

        end

        %% Gauss-Hermite Quadrature
        
        function [x,w] = ghermite(n)
            
            %% Discretized normal distribution.

            ip = 1:n-1;
            ap = sqrt(ip/2);
            CM = diag(ap,1)+diag(ap,-1);
            
            [Vp, Lp] = eig(CM);
            [discp, indp] = sort(diag(Lp));
            
            Vp = Vp(:,indp)';
            
            x = discp; % Discretized nodes.
            w = sqrt(pi)*Vp(:,1).^2; % Weights.
            
        end

        %% Normalized utility function.
        
        function unorm = utility(c,eps_j,par)
            %% CRRA utility.
            
            if par.sigma == 1
                utemp = log(c); % Log utility.
            else
                utemp = (c.^(1-par.sigma))./(1-par.sigma); % CRRA utility.
            end

            unorm = (eps_j.^((1-par.sigma)*(1-par.phi)))*utemp;
                        
        end
        
        %% Switching cost function.
        
        function c = cost(age,par)
            %% Quadratic cost function.
            
            c = exp(-(par.kappa(1) + par.kappa(2)*age + par.kappa(3)*age^2)); % Loss in human capital.

        end
        
        %% Tax function.
        
        function ydisp = tax_fun(ygross,par)
            %% Progressive tax function.
            
            ydisp = par.lambda*ygross^(1-par.phi); % After tax income.

        end
        
    end
end