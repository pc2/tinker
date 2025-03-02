c
c
c     ###################################################
c     ##  COPYRIGHT (C)  1993  by  Jay William Ponder  ##
c     ##              All Rights Reserved              ##
c     ###################################################
c
c     #################################################################
c     ##                                                             ##
c     ##  subroutine unitcell  --  get periodic boundary conditions  ##
c     ##                                                             ##
c     #################################################################
c
c
c     "unitcell" gets the periodic boundary box size and related
c     values from an external keyword file
c
c
      subroutine unitcell
      use bound
      use boxes
      use keys
      use math
      implicit none
      integer i,next
      real*8 boxmax
      character*20 keyword
      character*240 record
      character*240 string
c
c
c     set the default values for periodic boundary conditions
c
      use_bounds = .false.
      use_replica = .false.
c
c     set the default values for the unit cell variables
c
      orthogonal = .false.
      monoclinic = .false.
      triclinic = .false.
      octahedron = .false.
      dodecadron = .false.
      nonprism = .false.
      nosymm = .false.
      spacegrp = '          '
c
c     get keywords containing crystal lattice dimensions
c
      do i = 1, nkey
         next = 1
         record = keyline(i)
         call gettext (record,keyword,next)
         call upcase (keyword)
         string = record(next:240)
         if (keyword(1:7) .eq. 'X-AXIS ') then
            if (xbox .eq. 0.0d0)  read (string,*,err=10,end=10)  xbox
         else if (keyword(1:7) .eq. 'Y-AXIS ') then
            if (ybox .eq. 0.0d0)  read (string,*,err=10,end=10)  ybox
         else if (keyword(1:7) .eq. 'Z-AXIS ') then
            if (zbox .eq. 0.0d0)  read (string,*,err=10,end=10)  zbox
         else if (keyword(1:7) .eq. 'A-AXIS ') then
            if (xbox .eq. 0.0d0)  read (string,*,err=10,end=10)  xbox
         else if (keyword(1:7) .eq. 'B-AXIS ') then
            if (ybox .eq. 0.0d0)  read (string,*,err=10,end=10)  ybox
         else if (keyword(1:7) .eq. 'C-AXIS ') then
            if (zbox .eq. 0.0d0)  read (string,*,err=10,end=10)  zbox
         else if (keyword(1:6) .eq. 'ALPHA ') then
            if (alpha .eq. 0.0d0)  read (string,*,err=10,end=10)  alpha
         else if (keyword(1:5) .eq. 'BETA ') then
            if (beta .eq. 0.0d0)  read (string,*,err=10,end=10)  beta
         else if (keyword(1:6) .eq. 'GAMMA ') then
            if (gamma .eq. 0.0d0)  read (string,*,err=10,end=10)  gamma
         else if (keyword(1:11) .eq. 'OCTAHEDRON ') then
            octahedron = .true.
         else if (keyword(1:13) .eq. 'DODECAHEDRON ') then
            dodecadron = .true.
         else if (keyword(1:11) .eq. 'NOSYMMETRY ') then
            nosymm = .true.
         else if (keyword(1:11) .eq. 'SPACEGROUP ') then
            call getword (record,spacegrp,next)
         end if
   10    continue
      end do
c
c     use periodic boundary conditions if a cell was defined
c
      boxmax = max(xbox,ybox,zbox)
      if (boxmax .ne. 0.0d0)  use_bounds = .true.
c
c     set unspecified periodic boundary box lengths and angles
c
      if (use_bounds) then
         if (xbox .eq. 0.0d0)  xbox = boxmax
         if (ybox .eq. 0.0d0)  ybox = boxmax
         if (zbox .eq. 0.0d0)  zbox = boxmax
         if (alpha .eq. 0.0d0)  alpha = 90.0d0
         if (beta .eq. 0.0d0)  beta = 90.0d0
         if (gamma .eq. 0.0d0)  gamma = 90.0d0
c
c     determine the general periodic boundary lattice type
c
         if (nosymm) then
            triclinic = .true.
         else if (alpha.eq.90.0d0 .and. beta.eq.90.0d0
     &               .and. gamma.eq.90.0d0) then
            orthogonal = .true.
         else if (alpha.eq.90.0d0 .and. gamma.eq.90.0d0) then
            monoclinic = .true.
         else
            triclinic = .true.
         end if
      end if
c
c     set lattice values for non-prism periodic boundaries
c
      if (octahedron .or. dodecadron) then
         orthogonal = .false.
         monoclinic = .false.
         triclinic = .false.
         nonprism = .true.
         ybox = xbox
         if (octahedron) then
            zbox = xbox
         else if (dodecadron) then
            zbox = xbox * root2
         end if         
         alpha = 90.0d0
         beta = 90.0d0
         gamma = 90.0d0
      end if
      return
      end
