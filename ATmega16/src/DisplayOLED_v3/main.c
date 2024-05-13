/*
 * main.c
 *
 * Created: 5/26/2023 5:07:03 PM
 *  Author: adrio
 */ 

#define F_CPU 8000000UL
#include <xc.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <stdio.h>
#include "ssd1306.h"

uint8_t valor;
uint8_t altoADC;
uint8_t bajoADC;
uint16_t lectSensor;
uint16_t offset = 100;
float sensibilidadCorriente = 0.22;
uint8_t seleccion = 0;
uint8_t menuDetallado;
uint8_t IFoco = 0;
uint16_t num = 3000;
uint16_t mascara;
//uint16_t corriente;
uint16_t luminosidad;
uint16_t banderaLum = 0;

float voltajeSensor;
float corriente;
uint16_t corr = 0;
uint16_t ImaxB=0;
uint16_t IminB= 0;
char corrienteStr[4];
char lumStr[2];

uint16_t ADC_read(uint8_t canal){
	canal = canal & 0b00000111; // select adc channel between 0 to 7
	ADMUX |= canal;        //channel A0 selected
	ADCSRA |= (1<<ADSC); //Inicio de conversión
	while(!(ADCSRA&(1<<ADIF))); //Pollear la bandera de fin de conversión
	ADCSRA |= (1<<ADIF); //Apagar la bandera de fin de conversión
	bajoADC = ADCL;
	altoADC = ADCH;
	lectSensor = (altoADC << 8) + bajoADC; //Valor completo del sensor
	return lectSensor;
}

uint16_t lecturaCorriente(uint8_t numSensor){
	voltajeSensor = 0;
	corriente = 0;
	corr = 0;
	ImaxB=0;
	IminB= 0;
	
	for(int i = 0; i < 1000; i++)
	{
		voltajeSensor = ADC_read(numSensor) * (5.0 / 1023.0);//lectura del sensor
		corriente=((voltajeSensor-2.49)/sensibilidadCorriente); //Ecuación  para obtener la corriente
		
		if(corriente < 0) corriente = 0;
		corr = corriente * 1000;
		
		if(corr>ImaxB) ImaxB=corr;
		if(corr<IminB) IminB=corr;
		
		
	}
	corr = ((ImaxB-IminB)/2)-offset;
	serialSend_LC(corr);
	if(corr > 65000) corr = 0;
	return corr;
}

char nivelLuminosidad(uint8_t numSensor){
	luminosidad = ADC_read(numSensor);
	if(luminosidad > 0 && luminosidad < 200){
		banderaLum = 1;
		lumStr[0] = 'H';

	}else if(luminosidad > 201 && luminosidad < 300){
		banderaLum = 2;
		lumStr[0] = 'M';
		
	}else{
		banderaLum = 3;
		lumStr[0] = 'L';
	}
	
	return lumStr;
}

void serialSend_Menu(int valor){

	UDR = valor;
	while ( !( UCSRA & (1<<UDRE)));
	
	_delay_ms(10);
}

void serialSend_LC(uint16_t valor){
	uint8_t parte_baja = (uint8_t)valor; // Obtener los 8 bits menos significativos
	uint8_t parte_alta = (uint8_t)(valor >> 8);
	
	UDR = parte_alta;
	while ( !( UCSRA & (1<<UDRE)));
	
	
	UDR = parte_baja;
	while ( !( UCSRA & (1<<UDRE)));
	_delay_ms(10);
}

char *numAstring(uint16_t num, char *str){
	if(str == NULL)
	{
		return NULL;
	}
	sprintf(str, "%d", num);
	return str;
}

void DespliegueFoco1(void){
	SSD1306_SetPosition (13, 0) ;
	SSD1306_DrawString("> FOCO 1", BOLD);
	SSD1306_SetPosition (13, 10) ;
	SSD1306_DrawString("  FOCO 2", BOLD);
	SSD1306_SetPosition (13, 20) ;
	SSD1306_DrawString("  FOCO 3", BOLD);
	SSD1306_SetPosition (13, 30) ;
	SSD1306_DrawString("  FOCO 4", BOLD);
}

void DespliegueFoco2(void){
	SSD1306_SetPosition (13, 0) ;
	SSD1306_DrawString("  FOCO 1", BOLD);
	SSD1306_SetPosition (13, 10) ;
	SSD1306_DrawString("> FOCO 2", BOLD);
	SSD1306_SetPosition (13, 20) ;
	SSD1306_DrawString("  FOCO 3", BOLD);
	SSD1306_SetPosition (13, 30) ;
	SSD1306_DrawString("  FOCO 4", BOLD);
}

void DespliegueFoco3(void){
	SSD1306_SetPosition (13, 0) ;
	SSD1306_DrawString("  FOCO 1", BOLD);
	SSD1306_SetPosition (13, 10) ;
	SSD1306_DrawString("  FOCO 2", BOLD);
	SSD1306_SetPosition (13, 20) ;
	SSD1306_DrawString("> FOCO 3", BOLD);
	SSD1306_SetPosition (13, 30) ;
	SSD1306_DrawString("  FOCO 4", BOLD);
}

void DespliegueFoco4(void){
	SSD1306_SetPosition (13, 0) ;
	SSD1306_DrawString("  FOCO 1", BOLD);
	SSD1306_SetPosition (13, 10) ;
	SSD1306_DrawString("  FOCO 2", BOLD);
	SSD1306_SetPosition (13, 20) ;
	SSD1306_DrawString("  FOCO 3", BOLD);
	SSD1306_SetPosition (13, 30) ;
	SSD1306_DrawString("> FOCO 4", BOLD);
}

void InfoFoco1_corr(uint16_t Ip){
	SSD1306_SetPosition(13,0);
	SSD1306_DrawString("FOCO 1", BOLD);
	SSD1306_SetPosition (13, 10) ;
	SSD1306_DrawString("I: ", BOLD);
	SSD1306_DrawString(numAstring(Ip, corrienteStr), BOLD);
	SSD1306_DrawString(" mA", BOLD);
}

void InfoFoco2_corr(uint16_t Ip2){
	SSD1306_SetPosition(13,0);
	SSD1306_DrawString("FOCO 2", BOLD);
	SSD1306_SetPosition (13, 10) ;
	SSD1306_DrawString("I: ", BOLD);
	SSD1306_DrawString(numAstring(Ip2, corrienteStr), BOLD);
	SSD1306_DrawString(" mA", BOLD);
}

void InfoFoco3_corr(uint16_t Ip3){
	SSD1306_SetPosition(13,0);
	SSD1306_DrawString("FOCO 3", BOLD);
	SSD1306_SetPosition (13, 10) ;
	SSD1306_DrawString("I: ", BOLD);
	SSD1306_DrawString(numAstring(Ip3, corrienteStr), BOLD);
	SSD1306_DrawString(" mA", BOLD);
	SSD1306_SetPosition (13, 20) ;
}

void InfoFoco4_corr(uint16_t Ip4){
	SSD1306_SetPosition(13,0);
	SSD1306_DrawString("FOCO 4", BOLD);
	SSD1306_SetPosition (13, 10) ;
	SSD1306_DrawString("I: ", BOLD);
	SSD1306_DrawString(numAstring(Ip4, corrienteStr), BOLD);
	SSD1306_DrawString(" mA", BOLD);

}

void InfoFoco_luz(){
	SSD1306_SetPosition (13, 20) ;
	SSD1306_DrawString("Luz: ", BOLD);
	SSD1306_DrawString(lumStr, BOLD);
}

int main(void)
{
	
	DDRD = 0b11110000;
	DDRB = 0xFF;
	DDRC |= (1<<7);
	
	//PALABRAS DE CONTROL ADC
	ADCSRA = 0b10000111;
	ADMUX = 0b01000000;
	
	//PALABRAS DE CONTROL SERIAL
	UCSRA = 0;
	UCSRB |= (1 << TXEN);   /* Turn on transmission and reception */
	UCSRC |= (1 << URSEL) | (1 << UCSZ0) | (1 << UCSZ1); //8 BITS!! (vemos)
	UBRRL = 51; //BAUD_PRESCALE;            /* Load lower 8-bits of the baud rate */
	UBRRH = 0;//(BAUD_PRESCALE >> 8);
	
	//PALABRAS DE CONTROL DE INTERRUPCIONES EXTERNAS
	DDRB = 0xFF;
	GICR = 0b11000000;
	MCUCR = 0b00001010;
	
	sei();
	SSD1306_Init();
	SSD1306_ClearScreen();
	//menuDetallado = 0;

	while(1){

		if (seleccion == 0 && menuDetallado == 0){
			serialSend_LC(1);
			DespliegueFoco1();
			
		}
		else if(seleccion == 0 && menuDetallado == 1){
			SSD1306_Init();
			SSD1306_ClearScreen();
			while(menuDetallado == 1){
				uint16_t corr1 = lecturaCorriente(0);
				if(corr1 > 3000){
					PORTB &= ~(1<<PB0);
					_delay_ms(3000);
					PORTB |= (1<<PB0);
				}
				//_delay_ms(500);
				serialSend_LC(corr1);
				InfoFoco1_corr(corr1);

			}
			
		}
		else if(seleccion == 0 && menuDetallado == 2){
			SSD1306_Init();
			SSD1306_ClearScreen();
			while(menuDetallado == 2){
				//serialSend_LC(menuDetallado);
				nivelLuminosidad(4);
				InfoFoco_luz();
				
			}
		}
		
		else if (seleccion == 1 && menuDetallado == 0 ){
			serialSend_LC(2);
			DespliegueFoco2();
		}
		
		else if(seleccion == 1 && menuDetallado == 1){
	
			SSD1306_Init();
			SSD1306_ClearScreen();
			while(menuDetallado == 1){
				corriente = lecturaCorriente(1);
				if(corriente > 200){
					PORTB = PORTB & ~(1<<1);
					_delay_ms(3000);
					PORTB |= (1<<1);
				}
				InfoFoco2_corr(corriente);
				_delay_ms(500);

			}
		}
		
		else if(seleccion == 1 && menuDetallado == 2){
			SSD1306_Init();
			SSD1306_ClearScreen();
			while(menuDetallado == 2){
				nivelLuminosidad(5);
				InfoFoco_luz();
				_delay_ms(500);
			}
		}
		
		else if (seleccion == 2 &&  menuDetallado == 0){
			serialSend_LC(3);
			DespliegueFoco3();
	
		}
		else if(seleccion == 2 && menuDetallado == 1){
			
			SSD1306_Init();
			SSD1306_ClearScreen();
			while(menuDetallado == 1){
				corriente = lecturaCorriente(2);
				serialSend_LC(corriente);
				if(corriente > 3000){
					PORTB = PORTB & ~(1<<2);
					_delay_ms(3000);
					PORTB |= (1<<2);
				}
				
				InfoFoco3_corr(corriente);
				
			}
		}
		
		else if(seleccion == 2 && menuDetallado == 2){
			SSD1306_Init();
			SSD1306_ClearScreen();
			while(menuDetallado == 2){
				nivelLuminosidad(6);
				InfoFoco_luz();
				
			}
		}
		
		else if(seleccion == 3 && menuDetallado == 0){
			serialSend_LC(4);
			DespliegueFoco4();
			
		}
		
		else if(seleccion == 3 && menuDetallado == 1){
		
			SSD1306_Init();
			SSD1306_ClearScreen();
			while(menuDetallado == 1){
				corriente = lecturaCorriente(3);
				serialSend_LC(corriente);
				if(corriente > 3000){
					PORTB = PORTB & ~(1<<2);
					_delay_ms(3000);
					PORTB |= (1<<2);
				}
	
				InfoFoco4_corr(corriente);

			}
			
		}
		
		else if(seleccion == 3 && menuDetallado == 2){
			SSD1306_Init();
			SSD1306_ClearScreen();
			while(menuDetallado == 2){
				//serialSend(menuDetallado);
				nivelLuminosidad(7);
				//serialSend(banderaLum);
				InfoFoco_luz();
			
			}
		}
		
		/*
		else{
			seleccion = seleccion;
			menuDetallado = menuDetallado;
		}*/
	}
	
}


ISR (INT0_vect){
	
	_delay_ms(10);
	if(PIND & (~(1<<PD2))){
		seleccion++;
		if(seleccion == 4) seleccion = 0;
	}
}

ISR (INT1_vect){
	_delay_ms(50);
	//serialSend(623);
	if(PIND & (~(1<<PD3))){
		_delay_ms(50);
		if(PIND & (~(1<<PD3))){
			_delay_ms(50);
			menuDetallado++;
			if(menuDetallado == 3) menuDetallado = 0;

		}
	}
}