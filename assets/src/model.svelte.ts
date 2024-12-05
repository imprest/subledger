import type { Book, Ledger } from './types';

// type Status = 'idle' | 'loading' | 'loaded' | 'error';

class Model {
	navigating = $state(false);
	books = $state(<Book[]>[]);
	ledgers = $state(<Ledger[]>[]);
	ledger = $state(<Ledger>{});
	fin_year = $state();
	currentFocus: any;

	finYearExists(year: number) {
		const fin_years = model.books.map((b) => b.fin_year);
		return fin_years.includes(year);
	}

	captureCurrentFocus() {
		console.log(document.activeElement);
		this.currentFocus = document.activeElement;
	}

	restoreCurrentFocus() {
		this.currentFocus.focus();
		if (this.currentFocus && document.contains(this.currentFocus)) {
			this.currentFocus.first().focus();
		}
	}
}

export const model = new Model();
