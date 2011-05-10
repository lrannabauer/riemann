!     =====================================================
      subroutine rpn2(ixy,maxm,meqn,mwaves,mbc,mx,ql,qr,
     &                  auxl,auxr,wave,s,amdq,apdq)
!     =====================================================
!
!     # Aproximate Riemann solver for the nonlinear KPP system:
!
!     # q_t + sin(q)_x + cos(q)_y = 0
!
!     # Solve Riemann problems along one slice of data:
!     #  in the x-direction if ixy=1 
!     #  in the y-direction if ixy=2.

!     # On input, ql contains the state vector at the left edge of each cell
!     #           qr contains the state vector at the right edge of each cell

!     # On output, wave contains the waves,
!     #            s the speeds,
!     #            amdq the  left-going fluctuation 
!     #            apdq the right-going fluctuation 
!
!     # Note that the i'th Riemann problem has left state qr(i-1,:)
!     #                                    and right state ql(i,:)
!     # From the basic clawpack routines, this routine is called with ql = qr

      implicit double precision (a-h,o-z)
      dimension wave(meqn,mwaves,1-mbc:maxm+mbc)
      dimension    s(mwaves,1-mbc:maxm+mbc)
      dimension   ql(meqn,1-mbc:maxm+mbc)
      dimension   qr(meqn,1-mbc:maxm+mbc)
      dimension apdq(meqn,1-mbc:maxm+mbc)
      dimension amdq(meqn,1-mbc:maxm+mbc)
      
      pi=4.d0*datan(1.d0)

      do i=2-mbc,mx+mbc

        ul = qr(1,i-1)
        ur = ql(1,i  )

        if (ixy.eq.1) then
            fl = dsin(ul)
            fr = dsin(ur)

            ! The flux fedge at the cell interface is obtained by
            ! minimizing or maximizing the function sin(q) over the
            ! interval between the left and right states.

            if (ul.lt.ur) then
                !Minimum
                fedge = dmin1(fl,fr)
                if (ur-ul .gt. 2.d0*pi) then
                    fedge=-1.d0
                else
                    reml = dmod(ul,2.d0*pi)
                    remr = dmod(ur,2.d0*pi)
                    if (remr.gt.1.5d0*pi .and. reml.lt.1.5d0*pi) then
                        fedge=-1.d0
                    elseif (ur-ul .gt. remr+0.5d0*pi) then
                        fedge=-1.d0
                    endif
                endif
            else
                !Maximum
                fedge = dmax1(fl,fr)
                if (ul-ur .gt. 2.d0*pi) then
                    fedge=1.d0
                else
                    reml = dmod(ul,2.d0*pi)
                    remr = dmod(ur,2.d0*pi)
                    if (reml.gt.0.5d0*pi .and. remr.lt.0.5d0*pi) then
                        fedge=1.d0
                    elseif (ul-ur .gt. reml+1.5d0*pi) then
                        fedge=1.d0
                    endif
                endif
            endif
        else ! ixy == 2
            fl = dcos(ul)
            fr = dcos(ur)

            ! The flux fedge at the cell interface is obtained by
            ! minimizing or maximizing the function cos(q) over the
            ! interval between the left and right states.

            if (ul.lt.ur) then
                !Minimum
                fedge = dmin1(fl,fr)
                if (ur-ul .gt. 2.d0*pi) then
                    fedge=-1.d0
                else
                    reml = dmod(ul,2.d0*pi)
                    remr = dmod(ur,2.d0*pi)
                    if (remr.gt.1.d0*pi .and. reml.lt.1.d0*pi) then
                        fedge=-1.d0
                    elseif (ur-ul .gt. remr+1.d0*pi) then
                        fedge=-1.d0
                    endif
                endif
            else
                !Maximum
                fedge = dmax1(fl,fr)
                if (ul-ur .gt. 2.d0*pi) then
                    fedge=1.d0
                else
                    reml = dmod(ul,2.d0*pi)
                    remr = dmod(ur,2.d0*pi)
                    if (reml.lt.remr) then
                        fedge=1.d0
                    endif
                endif
            endif
        endif


        if (ul.ne.ur) then
            !Secant approximation
            s(1,i) = (fr-fl)/(ur-ul)
        else
            s(1,i) = 0.d0
        endif

        wave(1,1,i) = ur-ul

        amdq(1,i)= fedge - fl
        apdq(1,i)= fr - fedge

      enddo
     
      return
      end
