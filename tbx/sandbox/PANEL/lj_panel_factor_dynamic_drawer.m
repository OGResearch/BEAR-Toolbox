function [beta_draw] = lj_panel_factor_dynamic_drawer(Zeta_gibbs, phi_gibbs, B_gibbs, theta_gibbs, thetabar, Xi, d, rho, gama, Flocation, Fperiods, iSample)

  % identify the final period for which we are creating a path
  finalp=Flocation;

  % order number of the sample we are asking for
  ii = iSample;

  % recover B
  B=reshape(B_gibbs(:,ii),d,d);
  % obtain its choleski factor as the square of each diagonal element
  cholB=diag(diag(B).^0.5);

  % draw sigmatilde and phi
  phi=phi_gibbs(1,ii);

  % get requested theta and zeta samples for period Flocation
  theta=theta_gibbs(:,ii,finalp);
  zeta=Zeta_gibbs(finalp,ii);

  % initiate the record draws
  h = size(Xi,1);
  beta_draw=zeros(h,Fperiods);
    
  % generate forecasts recursively
  % for each iteration jj, repeat the process for periods T+1 to T+h
  for jj=1:Fperiods

    % update theta
    % draw the vector of shocks eta
    eta=cholB*mvnrnd(zeros(d,1),eye(d))';
    % update theta from its AR process
    theta=(1-rho)*thetabar+rho*theta+eta;

    % update sigma
    % draw the shock upsilon
    ups=normrnd(0,phi);
    % update zeta from its AR process
    zeta=gama*zeta+ups;

    beta_draw(:,jj) = Xi*theta;
    % repeat until values are obtained for T+h
  end

end