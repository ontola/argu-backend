Can only be used within a Box at the moment.

    const buttons = [{
      side: 'pro',
      icon: 'thumbs-up',
      label: 'Ik ben voor',
    }, {
      side: 'neutral',
      icon: 'pause',
      label: 'Neutraal',
    }, {
      side: 'con',
      icon: 'thumbs-down',
      label: 'Ik ben tegen',
    }];
    <BoxActions buttons={buttons} id="12345" />
