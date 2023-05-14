		  	// Import the functions you need from the SDKs you need
		  	import { initializeApp } from "https://www.gstatic.com/firebasejs/9.20.0/firebase-app.js";
		  	import { getDatabase, ref, set, child, push, update } from "https://www.gstatic.com/firebasejs/9.20.0/firebase-database.js";

		  	// Your web app's Firebase configuration
			const firebaseConfig = {
				apiKey: "AIzaSyBsyNvH0JlTzldg51uWzkadOnYLpewhYVs",
				authDomain: "creativeproject-12185.firebaseapp.com",
				databaseURL: "https://creativeproject-12185-default-rtdb.europe-west1.firebasedatabase.app",
				projectId: "creativeproject-12185",
				storageBucket: "creativeproject-12185.appspot.com",
				messagingSenderId: "990833384121",
				appId: "1:990833384121:web:72d1040a139abd74655968"
			};

			// Initialize Firebase
			const app = initializeApp(firebaseConfig);
			
			// Create DOM + listener + firebaseWrite

			// ELEMENT 1
			document.body.appendChild(document.createElement('BR'));
			document.body.appendChild(document.createElement('BR'));
			const colorLabel = document.createElement('LABEL');
			colorLabel.innerText = "Color: "
			document.body.appendChild(colorLabel);
			const colorElem = document.createElement('INPUT');
			document.body.appendChild(colorElem);

			colorElem.addEventListener('input', () => {
				const db = getDatabase();
				update(ref(db, 'table/'), {
					color: colorElem.value,
				});
			});

			// ELEMENT 2
			document.body.appendChild(document.createElement('BR'));
			document.body.appendChild(document.createElement('BR'));
			const numberLabel = document.createElement('LABEL');
			numberLabel.innerText = "Number: "
			document.body.appendChild(numberLabel);
			const numberElem = document.createElement('INPUT');
			numberElem.innerHTML = "type=number";
			document.body.appendChild(numberElem);

			numberElem.addEventListener('input', () => {
				const db = getDatabase();
				update(ref(db, 'table/'), {
					number: numberElem.value,
				});
			});
			





