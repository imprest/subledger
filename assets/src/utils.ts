const nf = new Intl.NumberFormat('en-GB', {
  minimumFractionDigits: 2,
  maximumFractionDigits: 2
});
const rf = new Intl.NumberFormat('en-GB', { minimumFractionDigits: 0 });
const df = new Intl.DateTimeFormat('en-GB');

export function realFmt(number: number) {
  if (number === null || number === 0) {
    return '';
  }
  return rf.format(number);
}

export function moneyFmt(number: number | string) {
  if (typeof number === 'string') {
    number = parseFloat(number);
  }
  if (number === null || number === 0) {
    return '';
  }
  return nf.format(number);
}

export function dateFmt(date: Date) {
  return df.format(date).replaceAll('/', '-');
}

export function compareValues(key: string, order = 'asc') {
  // eslint-disable-next-line
  return function (a: any, b: any) {
    const varA = typeof a[key] === 'string' ? a[key].toUpperCase() : a[key];
    const varB = typeof b[key] === 'string' ? b[key].toUpperCase() : b[key];

    let comparison = 0;
    if (varA > varB) {
      comparison = 1;
    } else if (varA < varB) {
      comparison = -1;
    }

    return order == 'desc' ? comparison * -1 : comparison;
  };
}

export function debounce(callback: (...args: unknown[]) => unknown, wait = 300) {
  let timeout: ReturnType<typeof setTimeout>;

  return (...args: unknown[]) => {
    clearTimeout(timeout);
    timeout = setTimeout(() => callback(...args), wait);
  };
}
